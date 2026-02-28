# Informe de Laboratorio: Estructura de Computadores

**Nombre del Estudiante:** Stiven Higuita Pulgarín  
**Fecha:** 25/02/2026  
**Asignatura:** Estructura de Computadores
 
**Enlace del repositorio en GitHub:** [enlace GitHub](https://github.com/stihiguita/Laboratorio-1-estructura-de-computadores-)
 

---

## 1. Análisis del Código Base

### 1.1. Evidencia de Ejecución
Adjunte aquí las capturas de pantalla de la ejecución del `programa_base.asm` utilizando las siguientes herramientas de MARS:
*   **MIPS X-Ray** (Ventana con el Datapath animado).
*   **Instruction Counter** (Contador de instrucciones totales).
*   **Instruction Statistics** (Desglose por tipo de instrucción).

(![MIPS X-RAY codigo base](<MIPS X-RAY C.BASE_1-1.png>))

(![INSTRUCTION COUNTER codigo base](<INSTRUCTION COUNTER C.BASE_1.png>))

(![INSTRUCTION STATISTIC codigo base ](<INSTRUCTION STATISTICS C.BASE_1.png>))

### 1.2. Identificación de Riesgos (Hazards)
Completa la siguiente tabla identificando las instrucciones que causan paradas en el pipeline:

| Instrucción Causante | Instrucción Afectada | Tipo de Riesgo (Load-Use, etc.) | Ciclos de Parada |
|----------------------|----------------------|---------------------------------|------------------|
| `lw $t6, 0($t5)`     | `mul $t7, $t6, $t0`  | Load-Use                        |       1           |
|  beq $t3, $t2, fin   |   |                  | Control (Branch)                |       1           |

### 1.2. Estadísticas y Análisis Teórico
Dado que MARS es un simulador funcional, el número de instrucciones ejecutadas será igual en ambas versiones. Sin embargo, en un procesador real, el tiempo de ejecución (ciclos) varía. Completa la siguiente tabla de análisis teórico:

| Métrica | Código Base | Código Optimizado |
|---------|-------------|-------------------|
| Instrucciones Totales (según MARS) |     94        |       79            |
| Stalls (Paradas) por iteración     |     2         |        1            |
| Total de Stalls (8 iteraciones)    |     16        |        8            |
| **Ciclos Totales Estimados** (Inst + Stalls) |     110        |      87  |
| **CPI Estimado** (Ciclos / Inst)   |     1.17      |       1.10          |

---

## 2. Optimización Propuesta

### 2.1. Evidencia de Ejecución (Código Optimizado)
Adjunte aquí las capturas de pantalla de la ejecución del `programa_optimizado.asm` utilizando las mismas herramientas que en el punto 1.1:
*   **MIPS X-Ray**.
*   **Instruction Counter**.
*   **Instruction Statistics**.

(![MIPS X-RAY codigo optimizado](<MIPS X-RAY C.OPTIIMIZADO_2.png>))

(![INSTRUCTION COUNTER codigo optimizado](<INSTRUCTION COUNTER C.OPTIMIZADO_2.png>))

(![INSTRUCTION STATISTIC codigo optimizado ](<INSTRUCTION STATISTIC C.OPTIMIZADO_2.png>))


### 2.2. Código Optimizado
Pega aquí el fragmento de tu bucle `loop` reordenado: 
loop:
    beq  $s0, $t3, fin        # si puntero X llegó al final, salir

    lw   $t4, 0($s0)          # cargar X[i]
    addi $s0, $s0, 4          # avanzar puntero X (rellena delay load)

    mul  $t5, $t4, $t0        # X[i] * A
    addu $t5, $t5, $t1        # + B

    sw   $t5, 0($s1)          # guardar resultado
    addi $s1, $s1, 4          # avanzar puntero Y

    j loop

```asm
# Pega tu código aquí
```
.data
    vector_x: .word 1, 2, 3, 4, 5, 6, 7, 8
    vector_y: .space 32
    const_a:  .word 3
    const_b:  .word 5
    tamano:   .word 8

.text
.globl main

main:
    # Inicialización
    la   $s0, vector_x        # puntero X
    la   $s1, vector_y        # puntero Y
    lw   $t0, const_a         # A
    lw   $t1, const_b         # B
    lw   $t2, tamano          # tamaño
    
    sll  $t2, $t2, 2          # tamaño en bytes (n * 4)
    addu $t3, $s0, $t2        # dirección final de X

loop:
    beq  $s0, $t3, fin        # si puntero X llegó al final, salir

    lw   $t4, 0($s0)          # cargar X[i]
    addi $s0, $s0, 4          # avanzar puntero X (rellena delay load)

    mul  $t5, $t4, $t0        # X[i] * A
    addu $t5, $t5, $t1        # + B

    sw   $t5, 0($s1)          # guardar resultado
    addi $s1, $s1, 4          # avanzar puntero Y

    j loop

fin:
    li $v0, 10
    syscall

### 2.2. Justificación Técnica de la Mejora
Explica qué instrucción moviste y por qué colocarla entre el `lw` y el `mul` elimina el riesgo de datos:
> [En el codigo base o original existia un riesgo de datos tipo Load-Use entra las instrucciones
 lw $t6, 0($t5)
 mul $t7, $t6, $t0
 la instruccion mul depende directamente del valor cargado por lw. en un pipeline MIPS de 5 (IF-ID-EX-MEM-WB) etapas, el dato elegido por lw solo esta disponible completamente despues de la etapa MEM/WM. Sin embargo, la istruccion mul necesita ese operando en su etapa EX, que ocurre inmediatamente en el siguiente ciclo y debido a esta dependencia inmediata (RAW- Read After Write), el proceso introduce un satll de ciclo, y que el valor aun no esta disponible cuando mul lo requiere.
 en la version optimizada se movio la instrucico addi $s0, $s0, 4 y queda en el siguiente orden.
 lw $t4, 0($s0)
 addi $s0, $s0, 4
 mul $t5, $t4, $t0
 esto elimina el stall ya que la instruccion addi $s0, $so, 4 no depende del registro cargado por lw, es independiente del resultado que usara lw y puede ejecutarse mientras el lw completa sus etapas MEM y WB. Al insertar esta instruccion entre lw y mul, se introduce por asi decirlo de manera natural el ciclo que ante era un satall]

---

## 3. Comparativa de Resultados

| Métrica | Código Base | Código Optimizado | Mejora (%) |
|---------|-------------|-------------------|------------|
| Ciclos Totales | 110  |        87         |     21% aproximadamente     |
| Stalls (Paradas) | 16 |      8          |      50%        |
| CPI |          | 1.17 |    1.10         |      6& aproximadamente |

---

## 4. Conclusiones
¿Qué impacto tiene la segmentación en el diseño de software de bajo nivel? ¿Es siempre posible eliminar todas las paradas?
> [CONCLUSION 1: la segementacion influye bastante en como se debe escribir el software a bajo nivel. Aunque un programa funcione correctamente, eso no significa que este aprovechando bien el procesador. cuando se trabaja en el lenguaje assembler no solo importa el resultado sea correcto, sino tambien como se ejecutan las instrucciones dentro del pipeline.

CONCLUSION 2: No siempre se pueden eliminar todas las paradas. Hay casos donde las dependencias son inevitables un ejemplo seria si una instruccion necesita obligatoriamente el resultado de la anterior, no hay forma de esconder si lo puedo llamar de esa manera ese tiempo de espera si no existe otra instruccion independiente que ejecutar en medio. 

En resumen muchas paradas se pueden reducir con una buena organizacion del codigo, pero no siempre es posible quitarlas todas.]
