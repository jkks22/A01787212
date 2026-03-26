# Breakout

## Cómo correr el juego

Abre el archivo `10_pong.html` con live server o directamente en cualquier navegador

---

## Objetivo

Destruir todos los bloques de la pantalla usando la pelota antes de que se acabe el tiempo (90 segundos) y sin quedarte sin vidas.

---

## Controles

| Tecla           | Acción                        |
|-----------------|-------------------------------|
| `←` Flecha izquierda | Mover el paddle a la izquierda |
| `→` Flecha derecha   | Mover el paddle a la derecha   |
| `R`             | Reiniciar el juego |

---

## Reglas

- Comienzas con **3 vidas**
- Si la pelota cae por debajo del paddle, pierdes una vida y la pelota se reinicia al centro
- Si pierdes todas las vidas, el juego termina con **GAME OVER**
- Si el tiempo llega a 0 antes de destruir todos los bloques, el juego termina con **¡TIEMPO!**
- Destruir todos los bloques antes de que se acabe el tiempo resulta en **victoria**
- Puedes tener un máximo de **5 vidas**

---

## Puntuación

- Cada bloque destruido otorga **10 puntos**.
- Al ganar, recibes un **bonus de tiempo**: `segundos restantes × 2` puntos adicionales.

---

## Gameplay

La pelota rebota automáticamente contra las paredes laterales y el techo. El jugador controla el paddle horizontal en la parte inferior de la pantalla para evitar que la pelota caiga y redirigirla hacia los bloques

### Bloques

Hay **5 filas de 10 bloques** cada una (50 bloques en total):
- Las filas **pares** se mueven horizontalmente y rebotan en los bordes (borde dorado).
- Las filas **impares** permanecen estáticas (borde blanco).

### Power-ups

Al destruir un bloque existe un **30% de probabilidad** de que suelte un power-up que cae hacia abajo. Si el paddle lo atrapa, se activa su efecto:

| Símbolo | Color       | Efecto                                      | Duración |
|---------|-------------|---------------------------------------------|----------|
| `W`     | Verde agua  | El paddle se vuelve el doble de ancho       | 7 segundos |
| `S`     | Amarillo    | La pelota reduce su velocidad a la mitad    | 5 segundos |
| `+1`    | Rosa        | Ganas una vida extra (máximo 5)             | Permanente |

---

## HUD (Información en pantalla)

- **Puntos** — esquina superior izquierda.
- **Tiempo restante** — centro superior (se vuelve rojo cuando quedan ≤ 15 segundos).
- **Vidas** — esquina superior derecha.
- **Leyenda de power-ups** — esquina inferior izquierda.
