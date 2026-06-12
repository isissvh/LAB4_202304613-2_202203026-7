# Laboratorio 4 - INF245

Arquitectura y Organizacion de Computadores

## Integrantes

| Integrante | Rol | Paralelo |
| --- | --- | --- |
| Héctor Chanampe | 202304613-2 | 200 |
| Isidora Villegas | 202203026-7 | 200 |

## Contexto

El laboratorio implementa dos subsistemas en ensamblador RISC-V para el simulador RARS. Ambos programas siguen el enunciado del Laboratorio 4: primero se estabiliza el nucleo del Portal F mediante la Secuencia de Pell y luego se validan llaves de 32 bits usando manipulacion de bits.

## Desafio 1: Estabilizacion del nucleo con numeros de Pell

El archivo `subsistema1.asm` recibe primero un entero `k`, que representa la cantidad de intensidades a calcular. Se valida que `3 <= k <= 15`. Luego se leen `k` intensidades `n` y para cada una se calcula el valor `P_n` de la Secuencia de Pell:

```text
P_0 = 0
P_1 = 1
P_n = 2 * P_(n-1) + P_(n-2), para n >= 2
```

La funcion `pell` fue implementada de forma recursiva. Para cada llamada se revisan primero los casos base `n = 0` y `n = 1`. Si `n >= 2`, se reserva espacio en la pila para guardar `ra` y registros `s`, se calcula recursivamente `P_(n-1)`, luego `P_(n-2)`, y finalmente se obtiene `P_n`.

La multiplicacion por 2 exigida por la recurrencia no usa instrucciones de multiplicacion: se implementa con `slli`, desplazando `P_(n-1)` un bit a la izquierda.

La salida tiene el formato solicitado:

```text
Intensidad [n] -> Pulso de estabilizacion: [Valor P_n]
```

## Desafio 2: Desencriptacion del Sello de Sombras

El archivo `subsistema2.asm` recibe primero un entero `m`, que indica cuantas llaves se evaluaran. El programa valida `1 <= m <= 20`, lee las llaves como enteros de 32 bits y las almacena en un arreglo de palabras reservado en memoria con `.space 80`.

Para cada llave se aplican dos reglas:

1. **Paridad de bits:** la llave debe tener una cantidad impar de bits encendidos. La funcion `validar_paridad_impar` recorre los 32 bits con `andi` para aislar el bit menos significativo, `xor` para acumular la paridad y `srli` para desplazar la llave.
2. **Consecutividad:** la llave no debe contener el patron `111`. La funcion `validar_sin_patron_111` usa corrimientos y mascaras: compara la llave con sus versiones desplazadas 1 y 2 posiciones, usando `and`. Si existe algun bloque de tres unos consecutivos, el resultado es distinto de cero y se rechaza.

Las llaves se imprimen en hexadecimal usando el servicio `34` de RARS, precedidas por `0x`. La salida para cada llave sigue estos formatos:

```text
0x[Valor HEX] -> LLAVE ACEPTADA - PORTAL ABIERTO
0x[Valor HEX] -> RECHAZADA (Fallo de Paridad)
0x[Valor HEX] -> RECHAZADA (Sobrecarga de Patron)
```

Si una llave falla ambas reglas, se informa primero el fallo de paridad, porque corresponde a la Regla 1 del enunciado.

## Supuestos utilizados

- El simulador utilizado es RARS.
- En el desafio 1 se acepta `n = 0` para cubrir el caso base `P_0 = 0`, aunque el enunciado describa las intensidades como enteros positivos.
- En el desafio 1 no se fija un limite superior para `n`; para valores muy grandes puede existir overflow de 32 bits o una ejecucion lenta por tratarse de recursion pura sin memoizacion.
- En el desafio 2 se asume un maximo de 20 llaves para reservar un arreglo estatico de 80 bytes.
- Las llaves del desafio 2 se ingresan en decimal y se muestran en hexadecimal.

## Instrucciones de compilacion y ejecucion en RARS

Para ambos subsistemas:

1. Abrir RARS.
2. Abrir `subsistema1.asm` o `subsistema2.asm`.
3. Ensamblar con F3.
4. Ejecutar con F5.
5. Ingresar los datos pedidos por consola.

Entradas:

- `subsistema1.asm`: ingresar `k` y luego las `k` intensidades `n`.
- `subsistema2.asm`: ingresar `m` y luego las `m` llaves de 32 bits en decimal.
