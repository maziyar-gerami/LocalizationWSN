function Positions = Position (xArea,nSensors)
    rng(100);
    Positions=unifrnd(1,xArea,[nSensors,2]);
end
