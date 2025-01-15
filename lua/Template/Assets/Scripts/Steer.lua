-- Copyright (c) 2025 Matteo Grasso
-- 
--     https://github.com/matteogrs/templates.o3de.minimal.kart-racing
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local Steer =
{
	Properties =
	{
		Speed = 45.0
	}
}

function Steer:OnActivate()
	self.angle = 0.0
	self.direction = 0.0
	
	self.tickHandler = TickBus.Connect(self)
	self.inputHandler = InputEventNotificationBus.Connect(self, InputEventNotificationId("Steer"))
end

function Steer:OnPressed(value)
	self.direction = -value
end

function Steer:OnReleased()
	self.direction = 0.0
end

function Steer:OnTick(deltaTime, time)
	self.angle = self.angle + (self.direction * self.Properties.Speed * deltaTime)

	TransformBus.Event.SetLocalRotation(self.entityId, Vector3(0.0, 0.0, Math.DegToRad(self.angle)))
end

function Steer:OnDeactivate()
	self.tickHandler:Disconnect()
	self.inputHandler:Disconnect()
end

return Steer
