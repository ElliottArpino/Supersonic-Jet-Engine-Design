# Supersonic-Jet-Engine-Design

**Supersonic Engine Design – AER710 Final Project**
This project presents the conceptual design and analysis of a fictional supersonic turbojet engine, capable of cruising at Mach 3.2 and completing a transatlantic flight from New York to London in under 3 hours. The engine is compared against the Pratt & Whitney J58, used in the SR-71 Blackbird, via parametric cycle analysis and performance trade-offs.

**Key Features**
- Supersonic inlet design using 3 oblique shocks + 1 normal shock, optimized via the Oswatitsch principle
- Parametric cycle analysis across Mach 0.85, 2.0, and 3.2 using MATLAB scripts
- Trade-off study evaluating:
    - Specific thrust
    - Thrust specific fuel consumption (TSFC)
    - Thermal, propulsive, and overall efficiency
- Comparison with the J58 engine at sea-level and cruise conditions

**Repository Contents**
report.pdf — Full project report with equations, figures, and conclusions
inlet_design.m — MATLAB code for multi-shock inlet optimization
cycle_analysis.m — MATLAB code for non-ideal turbojet parametric cycle modeling

**Results Highlights**
TSFC of 0.03 at sea-level — significantly better than typical values for existing engines
Greater thrust-to-mass flow than the J58
Optimized for cruise at Mach 2.0 with 9.5:1 compressor pressure ratio and 1700 K turbine inlet temperature
