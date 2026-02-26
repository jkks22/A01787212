/*
 * Example functions to practice JavaScript
 *
 * Josue Gomez Arteaga
 * 2026-02-24
 */

"use strict";

//encuentra el primer carácter que no se repite en una cadena
function firstNonRepeating(str) {
    const candidates = [];
    for (let i = 0; i < str.length; i++) {
        let found = false;
        for (let j = 0; j < candidates.length; j++) {
            if (candidates[j].char == str[i]) {
                candidates[j].count = candidates[j].count + 1;
                found = true;
            }
        }
        if (found == false) {
            candidates.push({ char: str[i], count: 1 });
        }
    }
    for (let i = 0; i < candidates.length; i++) {
        if (candidates[i].count == 1) {
            return candidates[i].char;
        }
    }
    return undefined;
}

//ordena una lista de números con el algoritmo bubble sort
function bubbleSort(arr) {
    const result = [];
    for (let i = 0; i < arr.length; i++) {
        result.push(arr[i]);
    }
    for (let i = 0; i < result.length; i++) {
        for (let j = 0; j < result.length; j++) {
            if (result[j] > result[j + 1]) {
                const temp = result[j];
                result[j] = result[j + 1];
                result[j + 1] = temp;
            }
        }
    }
    return result;
}

//invierte un arreglo y regresa uno nuevo
function invertArray(arr) {
    const result = [];
    for (let i = arr.length - 1; i >= 0; i--) {
        result.push(arr[i]);
    }
    return result;
}

//invierte un arreglo modificando el mismo arreglo
function invertArrayInplace(arr) {
    let left = 0;
    let right = arr.length - 1;
    while (left < right) {
        const temp = arr[left];
        arr[left] = arr[right];
        arr[right] = temp;
        left = left + 1;
        right = right - 1;
    }
    return arr;
}

//pone en mayúscula la primera letra de cada palabra
function capitalize(str) {
    if (str.length == 0) return '';
    const words = str.split(' ');
    let result = '';
    for (let i = 0; i < words.length; i++) {
        const firstLetter = words[i][0].toUpperCase();
        const rest = words[i].slice(1);
        if (i == 0) {
            result = firstLetter + rest;
        } else {
            result = result + ' ' + firstLetter + rest;
        }
    }
    return result;
}

//calcula el máximo común divisor con el algoritmo de Euclides
function mcd(a, b) {
    while (b != 0) {
        const temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

//convierte una cadena a Hacker Speak
function hackerSpeak(str) {
    let result = '';
    for (let i = 0; i < str.length; i++) {
        const c = str[i].toLowerCase();
        if (c == 'a') {
            result = result + '4';
        } else if (c == 'e') {
            result = result + '3';
        } else if (c == 'i') {
            result = result + '1';
        } else if (c == 'o') {
            result = result + '0';
        } else if (c == 's') {
            result = result + '5';
        } else {
            result = result + str[i];
        }
    }
    return result;
}

//regresa todos los factores de un número
function factorize(n) {
    const factors = [];
    for (let i = 1; i <= n; i++) {
        if (n % i == 0) {
            factors.push(i);
        }
    }
    return factors;
}

//quita los elementos duplicados de un arreglo
function deduplicate(arr) {
    const seen = [];
    for (let i = 0; i < arr.length; i++) {
        let alreadyIn = false;
        for (let j = 0; j < seen.length; j++) {
            if (seen[j] == arr[i]) {
                alreadyIn = true;
            }
        }
        if (alreadyIn == false) {
            seen.push(arr[i]);
        }
    }
    return seen;
}

//regresa la longitud de la cadena más corta de una lista
function findShortestString(arr) {
    if (arr.length == 0) return 0;
    let shortest = arr[0].length;
    for (let i = 0; i < arr.length; i++) {
        if (arr[i].length < shortest) {
            shortest = arr[i].length;
        }
    }
    return shortest;
}

//revisa si una cadena es un palíndromo
function isPalindrome(str) {
    const clean = [];
    for (let i = 0; i < str.length; i++) {
        const c = str[i].toLowerCase();
        if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
            clean.push(c);
        }
    }
    let left = 0;
    let right = clean.length - 1;
    while (left < right) {
        if (clean[left] != clean[right]) {
            return false;
        }
        left = left + 1;
        right = right - 1;
    }
    return true;
}

//ordena una lista de cadenas alfabéticamente (bubble sort)
function sortStrings(arr) {
    const result = [];
    for (let i = 0; i < arr.length; i++) {
        result.push(arr[i]);
    }
    for (let i = 0; i < result.length; i++) {
        for (let j = 0; j < result.length; j++) {
            if (result[j].localeCompare(result[j + 1]) > 0) {
                const temp = result[j];
                result[j] = result[j + 1];
                result[j + 1] = temp;
            }
        }
    }
    return result;
}

//calcula el promedio y la moda de una lista de números
function stats(arr) {
    if (arr.length == 0) return [0, 0];

    let sum = 0;
    for (let i = 0; i < arr.length; i++) {
        sum = sum + arr[i];
    }
    const average = sum / arr.length;

    const frequencies = [];
    for (let i = 0; i < arr.length; i++) {
        let found = false;
        for (let j = 0; j < frequencies.length; j++) {
            if (frequencies[j].num == arr[i]) {
                frequencies[j].count = frequencies[j].count + 1;
                found = true;
            }
        }
        if (found == false) {
            frequencies.push({ num: arr[i], count: 1 });
        }
    }

    let mode = frequencies[0].num;
    let maxCount = frequencies[0].count;
    for (let i = 0; i < frequencies.length; i++) {
        if (frequencies[i].count > maxCount) {
            maxCount = frequencies[i].count;
            mode = frequencies[i].num;
        }
    }

    return [average, mode];
}

//regresa la cadena más frecuente de una lista
function popularString(arr) {
    if (arr.length == 0) return '';
    const frequencies = [];
    for (let i = 0; i < arr.length; i++) {
        let found = false;
        for (let j = 0; j < frequencies.length; j++) {
            if (frequencies[j].str == arr[i]) {
                frequencies[j].count = frequencies[j].count + 1;
                found = true;
            }
        }
        if (found == false) {
            frequencies.push({ str: arr[i], count: 1 });
        }
    }

    let popular = frequencies[0].str;
    let maxCount = frequencies[0].count;
    for (let i = 0; i < frequencies.length; i++) {
        if (frequencies[i].count > maxCount) {
            maxCount = frequencies[i].count;
            popular = frequencies[i].str;
        }
    }
    return popular;
}

//revisa si un número es potencia de 2
function isPowerOf2(n) {
    if (n <= 0) return false;
    let current = 1;
    while (current < n) {
        current = current * 2;
    }
    if (current == n) {
        return true;
    } else {
        return false;
    }
}

//ordena una lista de números en orden descendente (bubble sort)
function sortDescending(arr) {
    const result = [];
    for (let i = 0; i < arr.length; i++) {
        result.push(arr[i]);
    }
    for (let i = 0; i < result.length; i++) {
        for (let j = 0; j < result.length; j++) {
            if (result[j] < result[j + 1]) {
                const temp = result[j];
                result[j] = result[j + 1];
                result[j + 1] = temp;
            }
        }
    }
    return result;
}

export {
    firstNonRepeating,
    bubbleSort,
    invertArray,
    invertArrayInplace,
    capitalize,
    mcd,
    hackerSpeak,
    factorize,
    deduplicate,
    findShortestString,
    isPalindrome,
    sortStrings,
    stats,
    popularString,
    isPowerOf2,
    sortDescending,
};