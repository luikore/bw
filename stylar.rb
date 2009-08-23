Stylar = Object.new

def Stylar.onstyleneeded sci, startp, endp
  sci.set_styling endp - startp, 1
end
