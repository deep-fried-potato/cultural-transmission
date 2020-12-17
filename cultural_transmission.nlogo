globals
[
 teachers
 meank
 sumMeank
 meanMeank
 Vk
 sumVk
 meanVk
 sumNumTeachers
 meanNumTeachers
 numTeachers
 xMax
]


turtles-own
[
 x
 age
 times-taught
 parent
 group
]


to setup
 clear-all

 ;;random-seed seed

 set sumNumTeachers 0
 set meanNumTeachers 0
 set meank 0
 set sumMeank 0
 set meanMeank 0
 set Vk 0
 set sumVk 0
 set meanVk 0

  crt N
  [
   set x 0.01
   setxy random-xcor random-ycor
   set color x
   set age 0
   set times-taught 0
   set group get-group
  ]

  reset-ticks

end




to go

  tick

  ask turtles [set age 1]

  set teachers turtles with [age = 1]

  set xMax max [x] of teachers

  vertical-cultural-transmission

  directly-biased-cultural-transmission

  update-data

  ask turtles with [age = 1] [die]

  plot-data

end

to vertical-cultural-transmission
  while [count turtles with [age = 0] < N] [
    ask one-of teachers with [reproduce?] [
      set times-taught times-taught + 1
      hatch 1 [
       set age 0
       setxy (max-pxcor - 1) * (x / xMax) 0
       set times-taught 0
       set parent myself
       set group [group] of parent
       ]
    ]
   ]
end


to directly-biased-cultural-transmission
  if primary-transmission-mode = "horizontal" [
    set teachers turtles with [age = 0]
  ]
  ask turtles with [age = 0] [
    ifelse random-float 1 < z [
     let teacher nobody
     let mygroup group
     let child-x x
     ifelse direct-biased-version = "Henrich" [
        set teacher max-one-of teachers with [segregation-constraints mygroup child-x] [x]
     ][
      let my-parent parent
      let possible-teachers teachers with [(who != [who] of my-parent) and (segregation-constraints mygroup child-x)]
      if 5 < count possible-teachers [
       set possible-teachers n-of 5 possible-teachers
      ]
      set teacher max-one-of possible-teachers [x]
     ]
    ask teacher [set times-taught times-taught + 1]
    ask parent [set times-taught times-taught - 1]
    set x (([x] of teacher - alpha) - (beta * ln(random-exponential 1)))
    set color x
    ][
    set x ((x - alpha) - (beta * ln(random-exponential 1)))
    set color x
    ]
    setxy (max-pxcor - 1) * (x / xMax) 0
   ]
end


to-report get-group
  let outcome "red"
  if random 100 > segregation-group-size [
    set outcome "black"
  ]
  report outcome
end

to-report segregation-constraints [child-group child-x]
  ifelse ((artificial-segregation? and group = child-group) or not artificial-segregation?) [
    ifelse (flocking? and abs (x - child-x) < flocking-tolerance) or not flocking? [
      report True
    ][
      report False
    ]
  ][
    report False
  ]
end

to-report reproduce?
  let top-turtles max-n-of (natural-selection-size * N) teachers [x]
  report (natural-selection and (member? self top-turtles)) or not natural-selection
  ;random-float 1 < exp (x - xMax)
end

to update-data
  set numTeachers count turtles with [age = 1 and times-taught > 0]

  set sumNumTeachers (sumNumTeachers + count turtles with [age = 1 and times-taught > 0])
  set meanNumTeachers (sumNumTeachers / ticks)

  set meank mean [times-taught] of turtles with [age = 1]
  set sumMeank (sumMeank + meank)
  set meanMeank (sumMeank / ticks)

  set Vk variance [times-taught] of turtles with [age = 1]
  set sumVk (sumVk + Vk)
  set meanVk (sumVk / ticks)

end



to plot-data

  set-current-plot "mean (black) max (red)"
  set-current-plot-pen "mean"
  plot mean [x] of turtles
  set-current-plot-pen "max"
  plot max [x] of turtles

end
@#$#@#$#@
GRAPHICS-WINDOW
237
10
512
286
-1
-1
8.1
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
72
10
135
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
10
71
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
137
10
200
43
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
351
97
384
alpha
alpha
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
5
386
97
419
beta
beta
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
6
81
98
114
N
N
1
500
200.0
1
1
NIL
HORIZONTAL

PLOT
607
10
807
160
mean (black) max (red)
time
x (skill level)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"mean" 1.0 0 -16777216 true "" ""
"max" 1.0 0 -2674135 false "" ""

MONITOR
521
212
583
257
NIL
meanVk
3
1
11

MONITOR
522
261
622
306
mean # Teachers
meanNumTeachers
0
1
11

SLIDER
5
303
97
336
z
z
0
1
1.0
.01
1
NIL
HORIZONTAL

MONITOR
519
11
576
56
N
count turtles
0
1
11

MONITOR
519
58
586
103
# Teachers
numTeachers
0
1
11

SWITCH
6
116
151
149
natural-selection
natural-selection
0
1
-1000

CHOOSER
6
152
135
197
direct-biased-version
direct-biased-version
"Shennan" "Henrich"
1

CHOOSER
3
226
176
271
primary-transmission-mode
primary-transmission-mode
"horizontal" "oblique"
1

SWITCH
292
392
466
425
artificial-segregation?
artificial-segregation?
1
1
-1000

SLIDER
292
431
470
464
segregation-group-size
segregation-group-size
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
632
178
832
328
counts of red and black
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"red" 1.0 0 -2674135 true "" "plot count turtles with [group = \"red\"]"
"black" 1.0 0 -16777216 true "" "plot count turtles with [group = \"black\"]"

SLIDER
292
495
464
528
natural-selection-size
natural-selection-size
0
1
0.5
0.01
1
NIL
HORIZONTAL

SWITCH
551
392
654
425
flocking?
flocking?
1
1
-1000

SLIDER
551
432
723
465
flocking-tolerance
flocking-tolerance
0
8
4.5
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a model of cultural transmission, which is the process by which skills are passed on between generations. This model illustrates the effect of various types of cultural transmission types, and different constraints on the agents.

## HOW IT WORKS

Agents represent social learners. Each agent possesses five state variables: age, x, times-taught, parent and group(only used in one case). Age=0 signifies that the agent is a member of the naïve (or learner) generation. x is a floating-point value that can be thought of as the skill level of a culturally transmitted trait. times-taught is an integer representing the number of times that the agent served as a teacher when a member of the parent generation. Each agent has a variable called group, which is used to differentiate agents when segregation is turned on. Each agent also has a variable called parent, which allows it to remember and identify its biological parent.

Global variables include: N, natural-selection, artificial-segregation?, segregation-group-size, flocking?, xMax, z, direct-biased-version, α, and β (copying error parameters). N is census population size.provides the integer used to initialize the random number generator at the start of each simulation run. When natural-selection=false, there is no natural selection in the model. When natural-selection=true, x is under natural selection. When the segregation variable set to true when there is segregation between the different groups, for the sake of simplicity, only two groups are considered. The group-size variable decides the proportion of the agents that will be in group 1 the rest will be in group 2. When the preferential-grouping variable is set to true learners will try to learn from teachers of similar x value. The maximum x value in the parent generation is recorded in xMax at the start of each time step. The model allows for two different versions of directly biased oblique cultural transmission. In Shennan’s version, the naïve agent attempts to copy the highest x value displayed among 5 randomly chosen members of the parent generation, excluding the biological parent of the naïve learner. In Henrich’s version, the naïve agent attempts to copy the highest x displayed among the entire parent generation.

Process overview:

  * Age: The N agents present at the beginning of the time step move from the naïve generation to the parent generation by changing their state variable, age, from 0 to 1.

  * Create naïve generation: Members of the parent generation (age=1) give rise to N naïve agents (age=0) either in the presence or absence of natural selection. During this process each offspring inherits its parent's x as its target value through vertical transmission<sup>[1]</sup>

  * Set segregation groups: If segregation is turned on, the learners will get the parent’s group, and it will not be allowed to learn from, or teach to learners from other group.

  * Transmission of skill level: Each learner can retain the parent’s x value, or undergo horizontal transmission, or oblique transmission

  * Update data: compile data from the current time step.

  * Cull parent generation: all members of the parent generation (age=1) are removed from the simulation.

The basic objective of each agent is to acquire x through social learning. Under some forms of cultural transmission, such as oblique transmission, the objective is to copy the highest x value among those known to the agent.

Naïve agents (age=0) learn socially by attempting to copy the x value displayed by a teacher. Transmission is imperfect.

Under vertical transmission, each member of the naïve generation learns from its parent. In this case, each agent can only sense its biological parent as a potential teacher.

However, under directly biased oblique and horizontal transmission, each naïve agent learns from an agent chosen out of a set of potential teachers. 

Under Shennan’s version of directly biased transmission, each member of the naïve generation has a set of potential teachers composed of a randomly chosen subset of 5 members of all teachers, excluding the naïve agent’s biological parent.<sup>[3]</sup> 

Under Henrich’s version of directly biased cultural transmission, each naive agent learns from the teacher that displays the highest x.<sup>[2]</sup>

Segregation:
Segregation is initialized in the setup, and two groups of agents are created with their respective group name as a state variable. When an agent gives birth to its child, the child gets the parent's group.

If segregation is turned on, the members of one group will not be able to teach or learn from members of the other group.

Flocking:
Flocking is a form of natural segregation. Agents of the child generation would like to learn from teachers of a similar skill level. The amount by which the skill level can be different is set with a tolerance slider.

If flocking is turned on, a child would only be able to learn from a teacher when their skill level difference is less than the tolerance.

## HOW TO USE IT

Adjust N for the population size, there are switches for natural-selection, flocking and artificial segregation. the primary-transmission-mode can be chosen to be oblique or horizontal. z defines the proportion of the population which gets the primary transmission mode. alpha and beta determine the noise which makes the transmission of skill imperfect. The group sizes for both can be set in terms of percentages, and the proportion of the population which gets to reproduce by natural selection can also be selected. flocking-tolerance determines the tolerance until which the child can choose it's teacher from. Once these parameters are set, click on setup, then click on go to run it indefinitely or click on step to proceed one at a time


## THINGS TO TRY (Our Hypotheses)

Horizontal vs Oblique transmission: How does the mode of transmission affect the mean skill level of agents after several generations. Keeping everything else same, the mode of transmission can be varied from horizontal to oblique and the mean skill level at the end of each run can be observed.

Effect of artificial segregation: How does the presence of artificial segregation affect the time for one group to go extinct. Under normal circumstances, if a trait doesn't play a role in the abilites (such as having a name/label), the organisms which exhibit that trait would go extinct with a random chance after several generations. When we enable artificial segregation, how would it affect the time taken for a group to totally die out.

Effect of flocking: How does the flocking-tolerance affect the mean skill level of agents after several generations, how is the rate of learning affected by it. 


## Results

1) Horizontal vs Oblique transmission:
At 3 different population sizes of 50, 100, 150; horizontal and oblique versions of transmission were run under both Shennan and Henrich models.
In both models, horizontal transmission outperforms the oblique transmission.(p<0.05)
![bar-graph-1](https://i.ibb.co/S3zhpyY/bar-graph-1.png)  
![bar-graph-2](https://i.ibb.co/FW1KQ4y/bar-graph-2.png)
2) Artificial Segregation:
For a 50/50 population divide, the time taken for one of the groups to go extinct was recorded in presence and absence of segregation, for both Shennan and Henrich models.
In both models, when segregation was present, one group becomes extinct very rapidly when compared to when segregation is absent.(p<0.05)

This can be explained by the fact that when the two groups are not allowed to communicate, any minor negative trend caused by copying imperfections is amplifed, and in natural selection, the less fit agents are purged. This results in less number of agents in that corresponding group for the next generation. With this lower population, it becomes even harder to overcome the difference. This process when repeated over several generations results in extinction of that group
![bar-graph-3](https://i.ibb.co/jDM367f/bar-graph-3.png)
![bar-graph-4](https://i.ibb.co/LnX2xdM/bar-graph-4.png)

3) Flocking:
We observed the effect of varying the flocking tolerance on the mean skill level of agents. For flocking tolerances of 4, 4.3 and 4.5, the mean skill level at the end was recorded for Henrich model. At flocking tolerance 4, the mean skill level showed a negative trend, while at 4.3, it showed a mildly positive trend, and at 4.5 it showed a positive trend each of which were different from each other(p<0.05). While in Shennan model, flocking had no effect on mean skill level.

This can be explained by the fact that the Henrich model always chooses the best teacher, and by limiting the range of teachers, the skill level is largely affected. If flocking is not applied, the average skill level of teachers is the maximum skill level, and when flocking is applied, it becomes equal to average skill level of all agents. However, in the Shennan model, one out of 5 randomly chosen agents is the teacher, hence, before and after applying flocking too, the average skill level of teaching agents remains the same.
![bar-graph-5](https://i.ibb.co/QNJPwC1/bar-graph-5.png)


## CREDITS AND REFERENCES

[1] Premo, L. S. (2016). Effective Population Size and the Effects of Demography on Cultural Diversity and Technological Complexity. American Antiquity, 81(04), 605–622. doi:10.1017/s000273160010099x 
[2] Henrich, Joseph (2004) Demography and cultural evolution: how adaptive cultural processes can produce maladaptive losses: the Tasmanian case. American Antiquity 69:197-214
[3] Shennan, Stephen J. (2001) Demography and cultural innovation: a model and its implications for the emergence of modern human culture. Cambridge Archaeological Journal 11:5-16.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1_shennan_with_natural_selection" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>meanMeank</metric>
    <metric>meanVk</metric>
    <metric>meanNumTeachers</metric>
    <metric>mean [x] of turtles</metric>
    <metric>(N - 1) / meanVk</metric>
    <enumeratedValueSet variable="direct-biased-version">
      <value value="&quot;Shennan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="z">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="5"/>
      <value value="15"/>
      <value value="25"/>
      <value value="35"/>
      <value value="45"/>
      <value value="55"/>
      <value value="65"/>
      <value value="75"/>
      <value value="85"/>
      <value value="95"/>
      <value value="105"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="20"/>
  </experiment>
  <experiment name="experiment2_henrich_without_natural_selection" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>meanMeank</metric>
    <metric>meanVk</metric>
    <metric>meanNumTeachers</metric>
    <metric>mean [x] of turtles</metric>
    <metric>(N - 1) / meanVk</metric>
    <enumeratedValueSet variable="direct-biased-version">
      <value value="&quot;Henrich&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="z">
      <value value="0"/>
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="5"/>
      <value value="15"/>
      <value value="25"/>
      <value value="35"/>
      <value value="45"/>
      <value value="55"/>
      <value value="65"/>
      <value value="75"/>
      <value value="85"/>
      <value value="95"/>
      <value value="105"/>
    </enumeratedValueSet>
    <steppedValueSet variable="seed" first="1" step="1" last="20"/>
  </experiment>
  <experiment name="horrizontal_vs_oblique_henrich" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [x] of turtles</metric>
    <metric>meanVk</metric>
    <enumeratedValueSet variable="N">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="primary-transmission-mode">
      <value value="&quot;horizontal&quot;"/>
      <value value="&quot;oblique&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="direct-biased-version">
      <value value="&quot;Henrich&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="z">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="horrizontal_vs_oblique_shennan" repetitions="25" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean [x] of turtles</metric>
    <metric>meanVk</metric>
    <enumeratedValueSet variable="N">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="primary-transmission-mode">
      <value value="&quot;horizontal&quot;"/>
      <value value="&quot;oblique&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="direct-biased-version">
      <value value="&quot;Shennan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="z">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="segregation_onOff_henrich" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <exitCondition>(count turtles with [group = "red"] = 0) or (count turtles with [group = "black"] = 0)</exitCondition>
    <metric>mean [x] of turtles</metric>
    <enumeratedValueSet variable="segregation-group-size">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="primary-transmission-mode">
      <value value="&quot;horizontal&quot;"/>
      <value value="&quot;oblique&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="direct-biased-version">
      <value value="&quot;Henrich&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="z">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="artificial-segregation?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flocking?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection-size">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flocking-tolerance">
      <value value="5.6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="segregation_onOff_shennan" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <exitCondition>(count turtles with [group = "red"] = 0) or (count turtles with [group = "black"] = 0)</exitCondition>
    <metric>mean [x] of turtles</metric>
    <enumeratedValueSet variable="segregation-group-size">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="primary-transmission-mode">
      <value value="&quot;horizontal&quot;"/>
      <value value="&quot;oblique&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="direct-biased-version">
      <value value="&quot;Shennan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="z">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="artificial-segregation?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flocking?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection-size">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flocking-tolerance">
      <value value="5.6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="flocking_henrich" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean [x] of turtles</metric>
    <enumeratedValueSet variable="segregation-group-size">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="primary-transmission-mode">
      <value value="&quot;horizontal&quot;"/>
      <value value="&quot;oblique&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="direct-biased-version">
      <value value="&quot;Henrich&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="z">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="artificial-segregation?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flocking?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="natural-selection-size">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flocking-tolerance">
      <value value="4"/>
      <value value="4.3"/>
      <value value="4.5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
