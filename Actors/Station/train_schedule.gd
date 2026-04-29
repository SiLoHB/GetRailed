class_name TrainSchedule
extends Resource


## Type of train to spawn
@export var train_type: Enum.TrainType = Enum.TrainType.NORMAL
## Delay in seconds after last train to spawn this one
@export var start_delay: float = 1.0
## Target station this train will try to get to
@export var target: String = "A"
