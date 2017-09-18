--region *
--Date
--此文件由[BabeLua]插件自动生成

local Collision = class("Collision",function () 
    return cc.Node:create();
end)

function Collision.create()
    local collision = Collision.new();
    return collision;
end

function Collision:initCollision(pointTab)
    self.obb = require("Other/OBB");
    self.pointNodeTab = {};
    self.collisionPointTab = pointTab;
    for i = 1, #self.collisionPoint do
        local oriPoint = self.collisionPoint[i];
        local midPoint = cc.p(oriPoint.x+self:getContentSize().width/2, oriPoint.y+self:getContentSize().height/2);
        local pointNode = self:addPointNodeToSprite(midPoint);
        table.insert(self.pointNodeTab, pointNode);
    end
end

function Collision:addPointNodeToSprite(pos)
    local pointNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 255));
     pointNode:setContentSize(cc.size(2, 2));
     pointNode:setPosition(pos);
     self:addChild(pointNode, 999);
     return pointNode;
end

--获取自定义碰撞盒的各个顶点
function Collision:getCollisionBoxVertex()
    local vertexTab = {};
    for i = 1, #self.pointNodeTab do
        local worldPos = self:convertToWorldSpace(cc.p(self.pointNodeTab[i]:getPositionX(), self.pointNodeTab[i]:getPositionY()));
        table.insert(vertexTab, worldPos);
    end
    return vertexTab;
end

--和其他矩形包围盒碰撞
function Collision:obbCollisionWithAABB(otherRectBox)
    if cc.rectIntersectsRect(self:getBoundingBox(), otherRectBox) then
        local vertexTab = self:getCollisionBoxVertex();
        local obb1 = self.obb.createWithPoints(vertexTab);
        local obb2 = self.obb.createWithRect(otherRectBox);
        return obb1:isCollisionWithOBB(obb2);
    else
        return false;
    end
end

--obb相互碰撞
function Collision:obbCollisionWithOBB(otherOBBCollision)
    
end

--删除碰撞点
function Collision:removeCollisionPoint()
    for key, val in ipairs(self.pointNodeTab) do
        self:removeChild(val);
    end
end

return Collision;

--endregion
