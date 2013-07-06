Effect = {}

function Effect.createGatherEffect(dir, time, color)
    local total = 10
    local p = CCParticleSystemQuad:create()
    p:setTotalParticles(total)
    p:setPositionType(kCCPositionTypeGrouped)
    p:setEmissionRate(total/0.3)
    p:setDuration(time)

    p:setEmitterMode(kCCParticleModeRadius)
    p:setLife(0.3) --ԽС�˶�Խ��
    p:setLifeVar(0.1)
    p:setStartSize(20) --���ݾ���ͼƬ
    p:setStartSizeVar(5)
    p:setEndSize(0)
    p:setEndSizeVar(0)

    p:setAngle(dir) --�����ڿ�λ���趨
    p:setAngleVar(100) --�������տռ������ķ���

    p:setStartRadius(20) --�����ڵ���Դ�С����������Χ�Ĵ�С
    p:setStartRadiusVar(5) --�����ڵĴ�С���� ����
    p:setEndRadius(3)
    p:setEndRadiusVar(2)
    p:setRotatePerSecond(0) --ÿ����ת�Ƕ�
    
   -- p:setPosition(pos) --�ڿڵ�λ��
    --p:setSourcePosition(pos)

    p:setStartColor(color)
    p:setStartColorVar(ccc4f(0, 0, 0, 0.0))

    p:setEndColor(ccc4f(0, 0.05, 1.0, 1.0))
    p:setEndColorVar(ccc4f(0, 0, 0, 0.0))

    p:setBlendAdditive(true)
    p:setTexture(CCTextureCache:sharedTextureCache():addImage("images/effects/circle2.png"))
	return p
end

function Effect.createFlyEffect(dir, time)
    local p = CCParticleSystemQuad:create()
    p:setTotalParticles(1000)
    --p:setPositionType(kCCPositionTypeRelative)
    
    p:setDuration(-1)
    p:setEmissionRate(200)
    --�ӷ���㵽 Ŀ�����˶�ʱ��ļ���

    p:setLife(0.5) --β���϶��ĳ���
    --�����ᵼ�� ���⵽���ھͱ�ϸ�� ��α�֤������·�����ǲ�˥���� �� ��˹���һ�δ�ϸ��ͬ�ļ���ȽϺ� startSize �� endSize һ�¾��ܹ���ֱ�ߵļ��ⷽ��

    p:setLifeVar(0)
    p:setStartSize(30)
    p:setStartSizeVar(0)
    p:setEndSize(20)
    p:setEndSizeVar(0)

    p:setAngle(dir) --�����ڿڵķ������ �Ƕ�
    p:setAngleVar(0)
    
    p:setPositionType(kCCPositionTypeGrouped)
    p:setEmitterMode(kCCParticleModeGravity)
    p:setSpeed(50) --��ʼ�ٶ�
    p:setSpeedVar(0)
    
    --������X Y ���������β��λ�� �Ƕ�190 Y ���� ʹβ���������� 

    p:setStartColor(ccc4f(0, 0.05, 1, 1))
    p:setEndColor(ccc4f(0, 0.05, 1, 1))

    p:setBlendAdditive(true)
    p:setTexture(CCTextureCache:sharedTextureCache():addImage("images/effects/circle2.png"))

    return p
end

function Effect.createBombEffect(time, color)
    local p = CCParticleSystemQuad:create()
    p:setTotalParticles(200)
    p:setPositionType(kCCPositionTypeRelative)
    p:setEmitterMode(kCCParticleModeGravity)
    p:setDuration(time) --��ըЧ��������ʱ��

    p:setEmissionRate(200) --��ըЧ��������ʱ��
    p:setGravity(ccp(0, 0))
    p:setSpeed(0) --��ըЧ�����ٶ� ��������Χ��� �ٶ�Խ��ը��ΧԽ��

    p:setRadialAccel(-0) --��ը���������ٶ�
    p:setTangentialAccel(-0)

    p:setAngle(90)
    p:setAngleVar(360)

    p:setLife(0.3)
    p:setLifeVar(0.5)

    p:setStartSize(20) --��ʼ�Ĵ�С  ���еĴ�С ���յĴ�С 3��֮��ı�����ϵ
    p:setStartSizeVar(10)
    p:setEndSize(0)
    p:setEndSizeVar(0)

    p:setPosVar(ccp(10, 10))--��ը��ʼ��Χ

    p:setStartColor(color)
    p:setStartColorVar(ccc4f(0, 0.45, 0, 0.31))
    p:setEndColor(ccc4f(0, 0.05, 1, 1))
    p:setBlendAdditive(true)
    p:setTexture(CCTextureCache:sharedTextureCache():addImage("images/effects/circle2.png"))
	return p
end

require "UI.Effect.Flame"
require "UI.Effect.Splash"