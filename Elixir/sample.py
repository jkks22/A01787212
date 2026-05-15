#!/usr/bin/env python3
"""
Sample Python file to test the highlighter
"""

import math
from typing import List, Optional

PI = 3.14159265
MAX_ITEMS = 1_000_000
HEX_VALUE = 0xFF
BINARY = 0b1010
COMPLEX_NUM = 3.5j


class Calculator:
    """A simple calculator class with various methods"""

    def __init__(self, initial: float = 0.0):
        self.value = initial
        self._history = []

    @property
    def history(self) -> List[float]:
        return self._history.copy()

    @staticmethod
    def factorial(n: int) -> int:
        # base case for recursion
        if n <= 1:
            return 1
        return n * Calculator.factorial(n - 1)

    def add(self, x: float) -> float:
        self.value += x
        self._history.append(self.value)
        return self.value

    def power(self, exp: int = 2) -> float:
        result = self.value ** exp
        return result


def fibonacci(n: int) -> List[int]:
    """Generate the first n Fibonacci numbers"""
    seq = [0, 1]
    while len(seq) < n:
        seq.append(seq[-1] + seq[-2])
    return seq[:n]


async def fetch_data(url: str) -> Optional[dict]:
    """Async function example with f-strings"""
    print(f"Fetching from {url}...")
    name = "world"
    greeting = f'Hello, {name}!'
    raw = r"C:\Users\test"
    multiline = """
    This is a
    multi-line string
    """
    return {"status": "ok", "url": url}


if __name__ == "__main__":
    calc = Calculator(10.0)
    calc.add(5.5)
    calc.add(-2.3)

    for i in range(1, 6):
        print(f"{i}! = {Calculator.factorial(i)}")

    fib = fibonacci(10)
    print(f"Fibonacci: {fib}")

    #comparison operators and boolean logic
    x, y = 10, 20
    if x < y and y > 0:
        result = (x + y) * 2 / (y - x)
        print(f"Result: {result:.2f}")

    #lambda and list comprehension
    squares = [n ** 2 for n in range(10) if n % 2 == 0]
    double = lambda v: v * 2
    print(list(map(double, squares)))
