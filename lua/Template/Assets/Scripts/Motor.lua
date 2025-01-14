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

local InputMultiHandler = require("Scripts.Utils.Components.InputUtils")

local Motor =
{
	Properties =
	{
		AccelerationRate = 1.25,
		BrakeStrength = 5.0,
		Drag = 0.1,
		MaxSpeed = 6.5
	}
}

function Motor:OnActivate()
	self.direction = 0.0
	self.speed = 0.0

	self.inputHandlers = InputMultiHandler.ConnectMultiHandlers
	{
		[InputEventNotificationId("Accelerate")] =
		{
			OnPressed = function(value) self:OnAccelerateChanged(value) end,
			OnHeld = function(value) self:OnAccelerateChanged(value) end,
			OnReleased = function(value) self:OnAccelerateChanged(0.0) end
		},
		[InputEventNotificationId("Brake")] =
		{
			OnPressed = function(value) self:OnBrakeChanged(value) end,
			OnHeld = function(value) self:OnBrakeChanged(value) end,
			OnReleased = function(value) self:OnBrakeChanged(0.0) end
		}
	}

	self.tickHandler = TickBus.Connect(self)
end

function Motor:OnAccelerateChanged(value)
	self.direction = value
end

function Motor:OnBrakeChanged(value)
	self.direction = -value
end

function Motor:OnTick(deltaTime, time)
	local tolerance = 0.01
	
	local acceleration
	if self.direction > tolerance then
		acceleration = self.Properties.AccelerationRate * self.direction
	elseif self.direction < -tolerance then
		acceleration = self.Properties.BrakeStrength * self.direction
	else
		acceleration = -self.Properties.Drag * self.speed * self.speed
	end

	self.speed = Math.Clamp(self.speed + (acceleration * deltaTime), 0.0, self.Properties.MaxSpeed)
	
	local transform = TransformBus.Event.GetWorldTM(self.entityId)
	local forwardAxis = transform:GetBasisY()
	local velocity = forwardAxis * self.speed

	CharacterControllerRequestBus.Event.AddVelocityForTick(self.entityId, velocity)
end

function Motor:OnDeactivate()
	self.tickHandler:Disconnect()
	self.inputHandlers:Disconnect()
end

return Motor
