from functools import wraps


def power_draw(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        result = func(self, *args, **kwargs)
        if self.stage == "executed":
            print(self.stage_result)
            pt = PowerTrace()
            pt.append(self.power())
        return result
    return wrapper


class PowerTrace(object):
    """
    Represents a power trace of the cpu. This is an append only data structure
    """

    _instance: "PowerTrace"

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(PowerTrace, cls).__new__(cls)
            cls.trace = []
        return cls._instance

    def append(self, trace_value: float):
        self.trace.append(trace_value)

    def close(self):
        with open('power-trace.txt', 'w') as f:
            for index, val in enumerate(self.trace):
                f.write(f"index: {val}\n")
