### Control Objective
Drill holes in parts supplied from the hopper.

### Control Specifications
1. When [SW1] (X24) on the operation panel is turned ON, system.
When [SW1] (X25) is turned ON, the system stop.
Store them in internal relay M100 and use them in all Outputs
2. When [PB1] (X20) on the operation panel is pressed, Supply command (Y0) for the hopper is turned ON.
When [PB1] (X20) is released, Supply command (Y0) is turned OFF. When Supply command (Y0) is turned ON, the hopper supplies a part.

3. When [SW1] (X20) on the operation panel is turned ON, the conveyor moves forward.

### Control of drill

1. When the sensor for Part under drill (X1) in the drill is turned ON, the conveyor stops.
2. When Start drilling (Y2) is turned ON, the drilling starts.
Start drilling (Y2) is turned OFF when Drilling (X0) is set ON.
3. When Start drilling (Y2) is turned ON, either Drilled correctly (X2) or Drilled wrong (X3)
is set ON after the drill machine has operated for one complete cycle. (The drill cannot be stopped in the middle of an operation.)
4. After Drilled correctly (X2) or Drilled wrong (X3) is confirmed, the work is carried and put on the tray at the right.
When multiple holes are drilled, Drilled wrong (X3) is set ON. In this exercise no specified
control for scrap parts exists.

### Control of error
Store errors caused by sensor X20 or sensor X21 in an internal memory M101. When there is an error, the Y20 LED lights up and every process stops immediately until the error resset. Errors are resset with button X22.
