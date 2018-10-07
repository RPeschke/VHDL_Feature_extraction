

from myhdl import *
import os,sys,inspect

from myhdl import *


default_width = 8

def Unsigned_int(val=0,width = default_width):
    return Signal(modbv(val, min=0, max=2**width))

def Signed_int(val=0,width = default_width):
    return Signal(intbv(val, min=-2**(width-1), max=2**(width-1)))


def bool_t():
    return Signal(bool(0))

TRUE  = Signal(bool(1))
FALSE = Signal(bool(0))


class AxisStreamBase:
    def __init__(self):
        self.tvalid = bool_t()
        self.tlast  = bool_t()
        self.tready  = bool_t()


class AxisInt(AxisStreamBase):
    def __init__(self):
        AxisStreamBase.__init__(self)
        self.tdata = Signed_int()





def reset_if(MAX_Index, Line, tlast):
    
    if Line > MAX_Index:
        Line.next=0
        tlast.next = True
    else:
        tlast.next = False
    
    
    

def doSomething(tdata):
    #reset(tdata)
    return tdata + 10


def AxiStimilus(AxOut,clk):
    
    
    w = int(5)
    t = int(10)
    
    Line = Signed_int(0)
    multi = Signed_int(100)

    #rs = reset(Line)

    @always(clk.posedge)
    def logic():
        #rs = reset(Line)
        ln = int(Line)
        #AxOut.tdata.next =int( (w**2)* multi //(w**2+(2*t-2*ln)**2) )
        
        if AxOut.tvalid and AxOut.tready:
            Line.next = Line +1
            AxOut.tdata.next =int( (w**2)* multi //(w**2+(2*t-2*ln)**2) )
        
        if Line < 20 and Line > 0:
            AxOut.tvalid.next = True
        elif Line == 0:
            AxOut.tvalid.next = False
            Line.next = Line +1
        
        reset_if(20, Line,AxOut.tlast )
        #multi.next = multi -1

    return logic


class FindPeakStates:
    waiting = 0
    begin = 1
    running = 2
    endOfRun = 3
    error = 100



def FindPeak(AxFeatureOut,AxIn,clk):
    maxValue = Signed_int(0)
    maxIndex = Signed_int(0)
    currentIndex = Signed_int(0)
    status =  Signed_int(FindPeakStates.waiting)

    @always(clk.posedge)
    def logic():
        
        if AxIn.tvalid:
            if  AxIn.tdata > maxValue:
                maxValue.next = AxIn.tdata
                maxIndex.next = currentIndex
            
            

        if status == FindPeakStates.waiting:
            maxValue.next = 0
            maxIndex.next = 0

        if status  == FindPeakStates.endOfRun:
            currentIndex.next = 0
            AxFeatureOut.tdata.next = maxValue
            AxFeatureOut.tvalid.next = True
            AxFeatureOut.tlast.next = True


        elif  status  == FindPeakStates.waiting:
            AxFeatureOut.tvalid.next  = False
            AxFeatureOut.tlast.next  = False

        elif status  == FindPeakStates.running:
            currentIndex.next = currentIndex + 1
            

    @always(clk.posedge)   
    def StateMachine():
        if status == FindPeakStates.waiting and AxIn.tvalid:
            status.next = FindPeakStates.begin
            AxIn.tready.next = True

        elif status == FindPeakStates.begin and AxIn.tvalid:
            status.next = FindPeakStates.running

        elif AxIn.tvalid and AxIn.tlast:
            status.next = FindPeakStates.endOfRun

        elif status  == FindPeakStates.endOfRun:
            status.next = FindPeakStates.waiting
            AxIn.tready.next = False

    @always(clk.posedge)
    def FSM_Control():
        pass

        



    
    return logic, StateMachine,FSM_Control



        


        

            






def AxiStream_test(clk,s_axPeak):

    s_axWave = AxisInt()

    e_axStim = AxiStimilus(s_axWave,clk) 

    e_peak = FindPeak(s_axPeak,s_axWave,clk)


    return e_axStim, e_peak


def test_axi():
  


    clk  = Signal(bool(0))
    s_axPeak = AxisInt()

    ax_test_obj = AxiStream_test(clk,s_axPeak)


    @always(delay(10))
    def clkgen():
        clk.next = not clk


    return ax_test_obj , clkgen 

def simulate(timesteps):
    tb = traceSignals(test_axi)
    sim = Simulation(tb)
    sim.run(timesteps)



simulate(20000)



def convert():
    clk= Signal(bool(0)) 
    
    s_axPeak = AxisInt()
    toVHDL(AxiStream_test, clk,s_axPeak)
    

convert()