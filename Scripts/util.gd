extends Node

func IsZero(d):
	var eps = 1.0e-9
	return d > -eps && d < eps

func SolveQuadric(c0, c1, c2, outArr):
	var p
	var q
	var D
	
	p = c1 / (2 * c0)
	q = c2 / c0
	
	D = p * p - q
	
	if (IsZero(D)):
		outArr.append(-p)
		return 1
	else: if (D < 0):
		return 0
	else :
		var sqrt_D = sqrt(D)
		
		outArr.append(sqrt_D - p)
		outArr.append(-sqrt_D - p)
		return 2

func SolveCubic(c0, c1, c2, c3, outArr):
	var num
	var sub
	var A
	var B
	var C
	var sq_A
	var p
	var q
	var cb_p
	var D
	
	A = c1 / c0
	B = c2 / c0
	C = c3 / c0
	
	sq_A = A * A
	p = 1.0/3 * (- 1.0/3 * sq_A + B)
	q = 1.0/2 * (2.0/27 * A * sq_A - 1.0/3 * A * B + C)
	
	cb_p = p * p * p
	D = q * q + cb_p
	
	if (IsZero(D)):
		if (IsZero(q)):
			outArr.append(0)
			num = 1
		else:
			var u = pow(-q, 1.0/3.0)
			outArr.append(2 * u)
			outArr.append(- u)
			num = 2
	else: if (D < 0):
		var phi = 1.0/3 * acos(-q / sqrt(-cb_p))
		var t = 2 * sqrt(-p)
		
		outArr.append(t * cos(phi))
		outArr.append(- t * cos(phi + PI / 3))
		outArr.append(- t * cos(phi - PI / 3))
		num = 3
	else:
		var sqrt_D = sqrt(D)
		var u = pow(sqrt_D - q, 1.0/3.0)
		var v = pow(sqrt_D + q, 1.0/3.0)
		
		outArr.append(u + v)
		num = 1
	
	sub = 1.0/3 * A
	
	var i = 0
	for s in outArr:
		outArr[i] = outArr[i] - sub
		i += 1
	
	return num

func SolveQuartic(c0, c1, c2, c3, c4, outArr):
	
	var arr = []
	var coeffs = [0.0,0.0,0.0,0.0]
	var z
	var u
	var v
	var sub
	var A
	var B
	var C
	var D
	var sq_A
	var p
	var q
	var r
	var num
	
	A = c1 / c0
	B = c2 / c0
	C = c3 / c0
	D = c4 / c0
	
	sq_A = A * A
	p = - 3.0/8 * sq_A + B
	q = 1.0/8 * sq_A * A - 1.0/2 * A * B + C
	r = - 3.0/256*sq_A*sq_A + 1.0/16*sq_A*B - 1.0/4*A*C + D
	
	if (IsZero(r)):
		coeffs[ 3 ] = q
		coeffs[ 2 ] = p
		coeffs[ 1 ] = 0
		coeffs[ 0 ] = 1
		
		num = SolveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3], arr)
	else:
		coeffs[ 3 ] = 1.0/2 * r * p - 1.0/8 * q * q
		coeffs[ 2 ] = - r
		coeffs[ 1 ] = - 1.0/2 * p
		coeffs[ 0 ] = 1
		
		SolveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3], arr)
		
		z = arr[0]
		
		u = z * z - r
		v = 2 * z - p
		
		if (IsZero(u)):
		    u = 0
		else: if (u > 0):
		    u = sqrt(u)
		else:
		    return 0
		
		if (IsZero(v)):
		    v = 0
		else: if (v > 0):
		    v = sqrt(v)
		else:
		    return 0
		
		coeffs[ 2 ] = z - u
		if (q < 0):
			coeffs[ 1 ] = -v
		else:
			coeffs[ 1 ] = v
		coeffs[ 0 ] = 1
		
		outArr
		num = SolveQuadric(coeffs[0], coeffs[1], coeffs[2], outArr)
		
		coeffs[ 2 ]= z + u
		if (q < 0):
			coeffs[ 1 ] = v
		else:
			coeffs[ 1 ] = -v
		coeffs[ 0 ] = 1
		
		SolveQuadric(coeffs[0], coeffs[1], coeffs[2], arr)
		for i in arr:
			outArr.append(i)
	
	sub = 0.25 * A
	
	var i = 0
	for oa in outArr:
		outArr[i] = outArr[i] - sub
		i += 1
	
	return num

func SolveBallisticArc(proj_pos, proj_speed, target_pos, target_velocity, gravity, outArr):
	var A = proj_pos.x
	var B = proj_pos.y
	var C = proj_pos.z
	var M = target_pos.x
	var N = target_pos.y
	var O = target_pos.z
	var P = target_velocity.x
	var Q = target_velocity.y
	var R = target_velocity.z
	var S = proj_speed
	
	var H = M - A
	var J = O - C
	var K = N - B
	var L = -0.5 * gravity
	
	var c0 = L*L
	var c1 = 2*Q*L
	var c2 = Q*Q + 2*K*L - S*S + P*P + R*R
	var c3 = 2*K*Q + 2*H*P + 2*J*R
	var c4 = K*K + H*H + J*J
	
	var times = []
	var numTimes = SolveQuartic(c0, c1, c2, c3, c4, times)
	
	times.sort()
	
	var solutions = []
	var numSolutions = 0
	
	for t in times:
		if (t <= 0):
			continue
		
		solutions.append(Vector3(((H+P*t)/t), ((K+Q*t-L*t*t)/ t), ((J+R*t)/t)))
		numSolutions += 1
	
	if (numSolutions > 0): outArr.append(solutions[0])
	if (numSolutions > 1): outArr.append(solutions[1])
	
	return numSolutions

func _sort_tuples(a, b):
	return a[1] < b[1]
#pass a ray if you dont want to check behind some stuff, make it ignore things in your group, and it will be modified
func FindInAngle(group, start, direction, angle, distance = -1, ray = null):
	var targets = get_tree().get_nodes_in_group(group)
	var found = []
	var d = distance
	
	for t in targets:
		var plong = t.getAimPos() - start
		var pd = plong.length()
		var p = plong.normalized()
		var q = direction.normalized()
		
		if (distance < 0 or pd < d):
			var a = q.angle_to(p)
			if (a <= angle):
				if (ray != null):
					ray.look_at(t.getAimPos(), Vector3(0,1,0))
					ray.cast_to = Vector3(0,0,-pd)
					ray.force_raycast_update()
					if (ray.is_colliding()):
						continue
				var inserted = false
				var i = 0
				for fa in found:
					if (a < fa[1]):
						inserted = true
						found.insert(i, [t, a])
						break
				if (!inserted):
					found.append([t, a])
	
	found.sort_custom(self, "_sort_tuples")
	var ret = []
	for f in found:
		ret.append(f[0])
	
	return ret

func solveConstantAcceleration(t, a, v, p):
	return p + (v * t) + (a * (t * t * 0.5))