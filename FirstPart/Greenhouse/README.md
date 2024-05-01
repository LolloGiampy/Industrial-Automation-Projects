
### Part 1
## Exercise 1 of 2
Consider a greenhouse composed by two independent adjacent sectors, as reported by the plant below.

Module 1: 50 * 10 * 3
Module 2: 10 * 10 * 4

The walls, including the separation between the two modules, are made of glass, and their thermal transmittance  is the one defined by a single glazing: 5.7 W/(m2⋅K).
1.	Taking into account the “cooling cheese” exercise defined in class, define a model to evaluate the evolution of the temperature in the next 24 hours taking into account:
a.	The forecasted external temperature 
b.	The forecasted sun radiation. This aspect has not been modelled in the “cooling cheese” problem. In this case, as simplifying hypothesis, we suppose that the sun radiation is just entering by the flat roof, also made by glass, at 95% (while the rest is reflected).
2.	Verify the model copying forecasted values for 24 hours for temperature and sun radiation from a web site (for example https://it.tutiempo.net/, https://it.tutiempo.net/genova.html?dati=allora)
3.	Suppose now to have one heat pump for each module. In the first module the heat pump has a maximum electric power of 25kW and 15kW in the second one (for thermal power, see COP for heat pumps in Internet or ask to AI tools). Suppose also to be able to perfectly measure the temperature in the first module and not at all in the second. Define control laws in discrete time (on samples of 2 s) for the two heat pumps based on:
a.	Relay
b.	PID
and evaluate them according to their ability to track the following temperatures (row 1 h of the day, row 2 desired T in °C in module 1, row 3 desired T in °C in module 2, 10 °C for both in the rest of the day):
10	11	12	13	14	15	16	17	18	19	20	21
5	5	10	10	10	9	8	7	7	7	7	6
8	8	15	15	15	13	14	14	8	8	5	4
 
4.	Evaluate the two methods taking into account separately, for each module:
a.	the quadratic deviation from the desired temperature on the whole day
b.	the energy required for feed the plant
