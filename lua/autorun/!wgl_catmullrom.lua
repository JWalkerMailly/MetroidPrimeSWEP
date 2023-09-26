
WGL = WGL || {};

WGL.CatmullRom = {};
WGL.CatmullRom.__index = WGL.CatmullRom;
function WGL.CatmullRom:New(steps, centripetal)

	local object = {
		Steps       = steps,
		Ups         = {},
		Nodes       = {},
		WayPoints   = {},
		WayRights   = {},
		Centripetal = centripetal || false
	};

	setmetatable(object, WGL.CatmullRom);
	return object;
end

function WGL.CatmullRom:Clear()

	self.Ups       = {};
	self.Nodes     = {};
	self.WayPoints = {};
	self.WayRights = {};
end

local function Slice(data, first, last, offset)

	local sliced = {};
	for i = first, last do sliced[i - offset] = data[i]; end
	return sliced;
end

function WGL.CatmullRom:GetNodes()

	local nodes         = self.Nodes;
	local wayPoints     = self.WayPoints;
	local nodesUnpacked = Slice(nodes, 1, #nodes, 0);
	nodesUnpacked[#nodes + 1] = wayPoints[#wayPoints - 1];

	return nodesUnpacked;
end

function WGL.CatmullRom:MoveLastSegment(waypoint, control, right, alpha)

	local steps          = self.Steps * 2;
	local upsCount       = #self.Ups - steps;
	local wayPointsCount = #self.WayPoints - 2;

	self.Ups       = Slice(self.Ups,       1, upsCount,       0);
	self.Nodes     = Slice(self.Nodes,     1, upsCount,       0);
	self.WayPoints = Slice(self.WayPoints, 1, wayPointsCount, 0);
	self.WayRights = Slice(self.WayRights, 1, wayPointsCount, 0);
	self:AddWayPoint(waypoint, right, alpha);
	self:AddWayPoint(control, right, alpha);
end

function WGL.CatmullRom:Interpolate(i, steps, knot0, knot1, knot2, knot3)

	local u     = i / steps;
	local point = Vector(0, 0, 0);
	point       = point + (u * u * u * (-knot0 + 3 * knot1 - 3 * knot2 + knot3) / 2);
	point       = point + (u * u * (2 * knot0 - 5 * knot1 + 4 * knot2 - knot3) / 2);
	point       = point + (u * (-knot0 + knot2) / 2);
	point       = point + knot1;

	return point;
end

function WGL.CatmullRom:CentripetalInterpolate(i, steps, knot0, knot1, knot2, knot3, alpha)

	local dis01 = knot1 - knot0;
	local dis12 = knot2 - knot1;
	local dis23 = knot3 - knot2;
	local vec01 = dis01 * dis01;
	local vec12 = dis12 * dis12;
	local vec23 = dis23 * dis23;
	local t1    = math.pow(vec01[1] + vec01[2] + vec01[3], alpha * 0.5);
	local t2    = math.pow(vec12[1] + vec12[2] + vec12[3], alpha * 0.5) + t1;
	local t3    = math.pow(vec23[1] + vec23[2] + vec23[3], alpha * 0.5) + t2;
	local t     = t1 + (i * ((t2 - t1) / steps));
	local t2t   = (t2-t) / (t2-t1);
	local tt1   = (t-t1) / (t2-t1);
	local A1    = (((t1-t) / t1) * knot0) + ((t / t1) * knot1);
	local A2    = (t2t * knot1) + (tt1 * knot2);
	local A3    = (((t3-t) / (t3-t2)) * knot2) + (((t-t2) / (t3-t2)) * knot3);
	local B1    = (((t2-t) / t2) * A1) + (t / t2 * A2);
	local B2    = (((t3-t) / (t3-t1)) * A2) + (((t-t1) / (t3-t1)) * A3);

	return (t2t * B1) + (tt1 * B2) + Vector(0.5, 0.5, 0.5);
end

function WGL.CatmullRom:AddWayPoint(wayPoint, wayRight, alpha)

	-- A catmullrom spline requires 4 or more points.
	local wayPoints     = self.WayPoints;
	local wayRights     = self.WayRights;
	local wayCount      = #wayPoints + 1;
	wayPoints[wayCount] = wayPoint;
	wayRights[wayCount] = wayRight;
	if (#wayPoints < 4) then return; end

	-- Define current spline parameters.
	local steps      = self.Steps;
	local ups        = self.Ups;
	local nodes      = self.Nodes;
	local nodesCount = #nodes;

	-- Define lookup locals for the current spline.
	local newNodeControlIndex = #wayPoints - 1;
	local newNodeIndex = newNodeControlIndex - 2;
	local previousNode = wayPoints[1];

	-- Define right vectors of the spline in order to compute the up directions at every node.
	local newRight      = wayRights[newNodeControlIndex];
	local previousRight = wayRights[newNodeControlIndex - 1];

	for i = 0, steps - 1 do

		local u = i / steps;
		local nodeIndex = nodesCount + i + 1;

		-- Compute the new catmullrom node based on the previous nodes.
		if (!self.Centripetal) then
			nodes[nodeIndex] = self:Interpolate(i, steps,
				wayPoints[newNodeIndex    ],
				wayPoints[newNodeIndex + 1],
				wayPoints[newNodeIndex + 2],
				wayPoints[newNodeIndex + 3]);
		else
			nodes[nodeIndex] = self:CentripetalInterpolate(i, steps,
				wayPoints[newNodeIndex    ],
				wayPoints[newNodeIndex + 1],
				wayPoints[newNodeIndex + 2],
				wayPoints[newNodeIndex + 3], alpha);
		end

		-- Compute the new up direction vector base on the newly generated node and its previous neighbor.
		if (nodesCount > 1) then previousNode = nodes[nodesCount + i]; end
		local right    = LerpVector(u, previousRight, newRight);
		local forward  = (nodes[nodeIndex] - previousNode);
		local up       = forward:Cross(right):GetNormalized();
		ups[nodeIndex] = up;
	end
end

function WGL.CatmullRom:RemoveFirstWayPoint()

	table.remove(self.WayPoints, 1);
	table.remove(self.WayRights, 1);

	local ups   = self.Ups;
	local nodes = self.Nodes;
	local steps = self.Steps;
	self.Ups    = Slice(ups, steps, #ups, steps);
	self.Nodes  = Slice(nodes, steps, #nodes, steps);
end

function WGL.CatmullRom:RemoveLastWayPoint()

	table.remove(self.WayPoints, #self.WayPoints);
	table.remove(self.WayRights, #self.WayRights);

	local ups   = self.Ups;
	local nodes = self.Nodes;
	local steps = self.Steps;
	self.Ups    = Slice(ups, #ups - steps, #ups, steps);
	self.Nodes  = Slice(nodes, #nodes - steps, #nodes, steps);
end

setmetatable(WGL.CatmullRom, {__call = WGL.CatmullRom.New });