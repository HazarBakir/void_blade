extends Camera2D
class_name Camera

func screen_shake(intensity: float, time: float):
	shake_manager.shake_object(self, intensity, time)
