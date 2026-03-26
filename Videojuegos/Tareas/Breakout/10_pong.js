/*
 * Breakout - basado en el código de Pong
 * Gilberto Echeverria / Josu
 * 2026
 */

"use strict";

// Global variables
const canvasWidth = 800;
const canvasHeight = 600;

let ctx;
let game;
let oldTime = 0;

let playerSpeed = 0.5;

let puntos = 0;
let vidas = 3;
let estado = "jugando"; //"jugando", "gameOver", "victoria", "tiempoAgotado"

//contrarreloj: 90 segundos
const TIEMPO_TOTAL = 90;
let tiempoRestante = TIEMPO_TOTAL;

//sprite sheet constants
const FRAME_WIDTH = 48;
const FRAME_HEIGHT = 64;
const ANIM_FRAMES = 3;
const ANIM_SPEED = 150;

const DIRECTION_ROW = {
    up:    0,
    right: 1,
    down:  2,
    left:  3,
};

//clase para el paddle
class Paddle extends GameObject {
    constructor(position, width, height, color) {
        super(position, width, height, color, "player");
        this.velocity = new Vector(0, 0);
        this.motion = {
            up:    { axis: "y", sign: -1 },
            down:  { axis: "y", sign:  1 },
            left:  { axis: "x", sign: -1 },
            right: { axis: "x", sign:  1 },
        };
        this.keys = [];
        this.animFrame = 0;
        this.animTimer = 0;
        this.currentRow = DIRECTION_ROW.down;
        this.anchoOriginal = width;
    }

    update(deltaTime) {
        this.velocity.x = 0;
        this.velocity.y = 0;
        for (const direction of this.keys) {
            const axis = this.motion[direction].axis;
            const sign = this.motion[direction].sign;
            this.velocity[axis] += sign;
        }
        this.velocity = this.velocity.normalize().times(playerSpeed);
        this.position = this.position.plus(this.velocity.times(deltaTime));
        this.clampWithinCanvas();
        this.updateAnimation(deltaTime);
    }

    updateAnimation(deltaTime) {
        const isMoving = this.keys.length > 0;
        if (isMoving) {
            const lastKey = this.keys[this.keys.length - 1];
            this.currentRow = DIRECTION_ROW[lastKey];
            this.animTimer += deltaTime;
            if (this.animTimer >= ANIM_SPEED) {
                this.animFrame = (this.animFrame + 1) % ANIM_FRAMES;
                this.animTimer = 0;
            }
        } else {
            this.animFrame = 0;
            this.animTimer = 0;
        }
        this.spriteRect = new Rect(
            this.animFrame * FRAME_WIDTH,
            this.currentRow * FRAME_HEIGHT,
            FRAME_WIDTH,
            FRAME_HEIGHT
        );
    }

    clampWithinCanvas() {
        if (this.position.y - this.halfSize.y < 0) this.position.y = this.halfSize.y;
        if (this.position.x - this.halfSize.x < 0) this.position.x = this.halfSize.x;
        if (this.position.y + this.halfSize.y > canvasHeight) this.position.y = canvasHeight - this.halfSize.y;
        if (this.position.x + this.halfSize.x > canvasWidth)  this.position.x = canvasWidth  - this.halfSize.x;
    }

    //agrandar el paddle por un tiempo (power-up)
    agrandar(duracion) {
        const nuevoAncho = this.anchoOriginal * 2;
        this.size.x = nuevoAncho;
        this.halfSize.x = nuevoAncho / 2;
        this.setCollider(nuevoAncho, this.size.y);
        //restaurar despues de 'duracion' ms
        setTimeout(() => {
            this.size.x = this.anchoOriginal;
            this.halfSize.x = this.anchoOriginal / 2;
            this.setCollider(this.anchoOriginal, this.size.y);
        }, duracion);
    }

    draw(ctx) {
        const x = this.position.x - this.halfSize.x;
        const y = this.position.y - this.halfSize.y;
        const w = this.size.x;
        const h = this.size.y;
        ctx.fillStyle = this.size.x > this.anchoOriginal ? "#00ffcc" : "white";
        ctx.fillRect(x, y, w, h);
        ctx.strokeStyle = "rgba(255,255,255,0.8)";
        ctx.lineWidth = 2;
        ctx.strokeRect(x, y, w, h);
    }
}

//clase para la pelota
class Ball extends GameObject {
    constructor(position, size, color) {
        super(position, size, size, color, "ball");
        this.speed = 0.4;
        this.velocity = new Vector(this.speed, this.speed);
    }

    update(deltaTime) {
        this.position = this.position.plus(this.velocity.times(deltaTime));
        this.updateCollider();

        if (this.position.y - this.halfSize.y < 0) {
            this.position.y = this.halfSize.y;
            this.velocity.y = Math.abs(this.velocity.y);
        }
        if (this.position.x - this.halfSize.x < 0) {
            this.position.x = this.halfSize.x;
            this.velocity.x = Math.abs(this.velocity.x);
        }
        if (this.position.x + this.halfSize.x > canvasWidth) {
            this.position.x = canvasWidth - this.halfSize.x;
            this.velocity.x = -Math.abs(this.velocity.x);
        }
    }

    reset() {
        this.position = new Vector(canvasWidth / 2, canvasHeight / 2);
        const dirX = Math.random() < 0.5 ? 1 : -1;
        this.velocity = new Vector(this.speed * dirX, -this.speed);
    }
}

//power ups
class PowerUp extends GameObject {
    constructor(position, tipo) {
        const colores = { agrandar: "#00ffcc", lento: "#ffee00", vida: "#ff69b4" };
        super(position, 20, 20, colores[tipo] || "white", "powerup");
        this.tipo = tipo;
        this.velocity = new Vector(0, 0.15); //cae hacia abajo
        this.active = true;
    }

    update(deltaTime) {
        this.position = this.position.plus(this.velocity.times(deltaTime));
        this.updateCollider();
        //desaparecer si cae fuera del canvas
        if (this.position.y > canvasHeight + 20) {
            this.active = false;
        }
    }

    draw(ctx) {
        if (!this.active) return;
        const x = this.position.x - this.halfSize.x;
        const y = this.position.y - this.halfSize.y;
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.position.x, this.position.y, this.halfSize.x, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = "white";
        ctx.lineWidth = 2;
        ctx.stroke();
        //letra indicando el tipo
        ctx.fillStyle = "black";
        ctx.font = "bold 11px monospace";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        const letras = { agrandar: "W", lento: "S", vida: "+1" };
        ctx.fillText(letras[this.tipo] || "?", this.position.x, this.position.y);
        ctx.textAlign = "left";
        ctx.textBaseline = "alphabetic";
    }
}

//clase par los bloques
const gifBloque = new Image();
gifBloque.src = "assets/sprites/fih.gif";

class Block extends GameObject {
    constructor(position, width, height, color, fila) {
        super(position, width, height, color, "block");
        this.active = true;
        this.fila = fila;
        //filas pares se mueven, impares no se mueven
        this.semueve = (fila % 2 == 0);
        this.velocidadMovimiento = (fila % 2 == 0) ? 0.08 : 0;
        this.direccion = Math.random() < 0.5 ? 1 : -1;
    }

    update(deltaTime) {
        if (!this.active || !this.semueve) return;
        this.position.x += this.velocidadMovimiento * this.direccion * deltaTime;
        //rebotar en los bordes
        if (this.position.x + this.halfSize.x > canvasWidth) {
            this.position.x = canvasWidth - this.halfSize.x;
            this.direccion = -1;
        }
        if (this.position.x - this.halfSize.x < 0) {
            this.position.x = this.halfSize.x;
            this.direccion = 1;
        }
        this.updateCollider();
    }

    draw(ctx) {
        if (!this.active) return;
        const x = this.position.x - this.halfSize.x;
        const y = this.position.y - this.halfSize.y;
        const w = this.size.x;
        const h = this.size.y;

        if (gifBloque.complete && gifBloque.naturalWidth > 0) {
            ctx.drawImage(gifBloque, x, y, w, h);
        } else {
            ctx.fillStyle = this.color;
            ctx.fillRect(x, y, w, h);
        }

        //borde: dorado si se mueve, blanco si no
        ctx.strokeStyle = this.semueve ? "rgba(255, 220, 0, 0.9)" : "rgba(255, 255, 255, 0.6)";
        ctx.lineWidth = this.semueve ? 2 : 1.5;
        ctx.strokeRect(x + 1, y + 1, w - 2, h - 2);
    }
}

//juego
class Game {
    constructor() {
        this.ping = document.createElement("audio");
        this.ping.src = "assets/audio/sound_effect.wav";

        this.powerups = [];

        this.createEventListeners();
        this.initObjects();
    }

    initObjects() {
        this.background = new GameObject(new Vector(canvasWidth / 2, canvasHeight / 2), canvasWidth, canvasHeight);
        this.background.setSprite("assets/sprites/fondo.jpg");

        this.paddle = new Paddle(new Vector(canvasWidth / 2, canvasHeight - 40), 100, 20, "white");

        this.ball = new Ball(new Vector(canvasWidth / 2, canvasHeight / 2), 20, "white");
        this.ball.setSprite("assets/sprites/mi_bombo.png");

        this.powerups = [];
        this.blocks = [];
        this.crearBloques();
    }

    crearBloques() {
        const colores = ["red", "orange", "yellow", "green", "blue"];
        const filas = 5;
        const columnas = 10;
        const anchoBloque = 70;
        const altoBloque = 20;
        const separacion = 5;
        const offsetX = (canvasWidth - (columnas * (anchoBloque + separacion) - separacion)) / 2;
        const offsetY = 60;

        for (let f = 0; f < filas; f++) {
            for (let c = 0; c < columnas; c++) {
                const x = offsetX + c * (anchoBloque + separacion) + anchoBloque / 2;
                const y = offsetY + f * (altoBloque + separacion) + altoBloque / 2;
                this.blocks.push(new Block(new Vector(x, y), anchoBloque, altoBloque, colores[f % colores.length], f));
            }
        }
    }

    spawnPowerUp(position) {
        //30% de probabilidad de soltar un power-up
        if (Math.random() > 0.3) return;
        const tipos = ["agrandar", "lento", "vida"];
        const tipo = tipos[Math.floor(Math.random() * tipos.length)];
        this.powerups.push(new PowerUp(new Vector(position.x, position.y), tipo));
    }

    aplicarPowerUp(tipo) {
        if (tipo == "agrandar") {
            this.paddle.agrandar(7000); //7 segundos
        } else if (tipo == "lento") {
            const velActual = this.ball.speed;
            this.ball.speed = velActual * 0.5;
            this.ball.velocity = this.ball.velocity.normalize().times(this.ball.speed);
            setTimeout(() => {
                this.ball.speed = velActual;
                this.ball.velocity = this.ball.velocity.normalize().times(this.ball.speed);
            }, 5000); //5 segundos
        } else if (tipo == "vida") {
            vidas = Math.min(vidas + 1, 5);
        }
    }

    draw(ctx) {
        this.background.draw(ctx);

        for (let block of this.blocks) {
            block.draw(ctx);
        }

        for (let pu of this.powerups) {
            pu.draw(ctx);
        }

        this.paddle.draw(ctx);
        this.ball.draw(ctx);

        //HUD
        ctx.fillStyle = "white";
        ctx.font = "bold 20px monospace";
        ctx.fillText("Puntos: " + puntos, 20, 25);
        ctx.fillText("Vidas: " + vidas, canvasWidth - 130, 25);

        //contrarreloj, cambia a rojo si quedan menos de 15 segundos
        const segs = Math.ceil(tiempoRestante);
        ctx.fillStyle = segs <= 15 ? "red" : "white";
        ctx.font = "bold 22px monospace";
        ctx.textAlign = "center";
        ctx.fillText("⏱ " + segs + "s", canvasWidth / 2, 25);
        ctx.textAlign = "left";

        //texto para power-ups
        ctx.fillStyle = "#00ffcc";
        ctx.font = "13px monospace";
        ctx.fillText("W = paddle grande", 10, canvasHeight - 40);
        ctx.fillStyle = "#ffee00";
        ctx.fillText("S = pelota lenta", 10, canvasHeight - 24);
        ctx.fillStyle = "#ff69b4";
        ctx.fillText("+1 = vida extra", 10, canvasHeight - 8);

        //Game Over
        if (estado == "gameOver" || estado == "tiempoAgotado") {
            ctx.fillStyle = "rgba(0, 0, 0, 0.65)";
            ctx.fillRect(0, 0, canvasWidth, canvasHeight);
            ctx.fillStyle = "red";
            ctx.font = "bold 64px monospace";
            ctx.textAlign = "center";
            ctx.fillText(estado == "tiempoAgotado" ? "¡TIEMPO!" : "GAME OVER", canvasWidth / 2, canvasHeight / 2 - 20);
            ctx.fillStyle = "white";
            ctx.font = "24px monospace";
            ctx.fillText("Puntos: " + puntos, canvasWidth / 2, canvasHeight / 2 + 40);
            ctx.font = "18px monospace";
            ctx.fillText("Presiona R para reiniciar", canvasWidth / 2, canvasHeight / 2 + 80);
            ctx.textAlign = "left";
        }

        //Victoria
        if (estado == "victoria") {
            ctx.fillStyle = "rgba(0, 0, 0, 0.65)";
            ctx.fillRect(0, 0, canvasWidth, canvasHeight);
            ctx.fillStyle = "yellow";
            ctx.font = "bold 64px monospace";
            ctx.textAlign = "center";
            ctx.fillText("¡GANASTE!", canvasWidth / 2, canvasHeight / 2 - 20);
            ctx.fillStyle = "white";
            ctx.font = "24px monospace";
            ctx.fillText("Puntos: " + puntos, canvasWidth / 2, canvasHeight / 2 + 40);
            ctx.font = "18px monospace";
            ctx.fillText("Presiona R para reiniciar", canvasWidth / 2, canvasHeight / 2 + 80);
            ctx.textAlign = "left";
        }
    }

    update(deltaTime) {
        if (estado != "jugando") return;

        //contrarreloj
        tiempoRestante -= deltaTime / 1000;
        if (tiempoRestante <= 0) {
            tiempoRestante = 0;
            estado = "tiempoAgotado";
            return;
        }

        this.paddle.update(deltaTime);
        this.ball.update(deltaTime);

        //ctualizar bloques que se mueven
        for (let block of this.blocks) {
            block.update(deltaTime);
        }

        //actualizar power-ups
        for (let pu of this.powerups) {
            if (!pu.active) continue;
            pu.update(deltaTime);
            //colision power-up con paddle
            if (boxOverlap(pu, this.paddle)) {
                this.aplicarPowerUp(pu.tipo);
                pu.active = false;
            }
        }
        this.powerups = this.powerups.filter(pu => pu.active);

        //sonido en paredes
        if (this.ball.position.y - this.ball.halfSize.y <= 0 ||
            this.ball.position.x - this.ball.halfSize.x <= 0 ||
            this.ball.position.x + this.ball.halfSize.x >= canvasWidth) {
            this.ping.currentTime = 0;
            this.ping.play();
        }

        //colision pelota con paddle
        if (boxOverlap(this.ball, this.paddle)) {
            this.ball.position.y = this.paddle.position.y - this.paddle.halfSize.y - this.ball.halfSize.y;
            this.ball.velocity.y = -Math.abs(this.ball.velocity.y);
            this.ping.currentTime = 0;
            this.ping.play();
        }

        //colision pelota con bloques
        for (let block of this.blocks) {
            if (!block.active) continue;
            if (boxOverlap(this.ball, block)) {
                block.active = false;
                puntos += 10;
                this.ball.velocity.y *= -1;
                this.ping.currentTime = 0;
                this.ping.play();
                this.spawnPowerUp(block.position);
                break;
            }
        }

        //Victoria
        if (!this.blocks.some(b => b.active)) {
            //bonus de tiempo restante
            puntos += Math.floor(tiempoRestante) * 2;
            estado = "victoria";
            return;
        }

        //perder vida
        if (this.ball.position.y - this.ball.halfSize.y > canvasHeight) {
            vidas--;
            if (vidas <= 0) {
                estado = "gameOver";
            } else {
                this.ball.reset();
            }
        }
    }

    createEventListeners() {
        window.addEventListener('keydown', (event) => {
            if (event.key == 'ArrowLeft') {
                event.preventDefault();
                this.addKey(this.paddle, 'left');
            } else if (event.key == 'ArrowRight') {
                event.preventDefault();
                this.addKey(this.paddle, 'right');
            } else if (event.key == 'r' || event.key == 'R') {
                if (estado != "jugando") {
                    puntos = 0;
                    vidas = 3;
                    tiempoRestante = TIEMPO_TOTAL;
                    estado = "jugando";
                    this.initObjects();
                }
            }
        });

        window.addEventListener('keyup', (event) => {
            if (event.key == 'ArrowLeft') this.delKey(this.paddle, 'left');
            if (event.key == 'ArrowRight') this.delKey(this.paddle, 'right');
        });
    }

    addKey(player, direction) {
        if (!player.keys.includes(direction)) player.keys.push(direction);
    }

    delKey(player, direction) {
        if (player.keys.includes(direction)) player.keys.splice(player.keys.indexOf(direction), 1);
    }
}


function main() {
    const canvas = document.getElementById('canvas');
    canvas.width = canvasWidth;
    canvas.height = canvasHeight;
    ctx = canvas.getContext('2d');

    game = new Game();

    drawScene(0);
}


function drawScene(newTime) {
    let deltaTime = newTime - oldTime;
    if (deltaTime > 100) deltaTime = 16;

    ctx.clearRect(0, 0, canvasWidth, canvasHeight);

    game.update(deltaTime);
    game.draw(ctx);

    oldTime = newTime;
    requestAnimationFrame(drawScene);
}