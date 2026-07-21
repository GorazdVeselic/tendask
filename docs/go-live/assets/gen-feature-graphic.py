# -*- coding: utf-8 -*-
from PIL import Image, ImageFont, ImageDraw
SRC='docs/go-live/assets/feature-graphic-1024x500.png'
A='docs/go-live/assets'
FONT='assets/fonts/PlusJakartaSans-VariableFont_wght.ttf'
COLOR=(240,245,240); SIZE=38; WGHT=400; CX=638; CY=328
EX0,EX1,EY0,EY1=452,822,296,356

# 1) BASE: erase subtitle band, no text
base=Image.open(SRC).convert('RGB'); px=base.load()
for y in range(EY0,EY1):
    cl=px[EX0,y]; cr=px[EX1,y]; span=EX1-EX0
    for x in range(EX0+1,EX1):
        t=(x-EX0)/span
        px[x,y]=tuple(int(cl[i]+(cr[i]-cl[i])*t) for i in range(3))
BASE=A+'/feature-graphic-base-1024x500.png'
base.save(BASE)
print('base saved', BASE)

# 2) render helper: base + centered subtitle
def render(text,out):
    im=Image.open(BASE).convert('RGB')
    d=ImageDraw.Draw(im); f=ImageFont.truetype(FONT,SIZE)
    try: f.set_variation_by_axes([WGHT])
    except Exception: pass
    d.text((CX,CY),text,font=f,fill=COLOR,anchor='mm'); im.save(out)
render('Your garden journal',A+'/feature-graphic-en-1024x500.png')
render('Dein Gartentagebuch',A+'/feature-graphic-de-1024x500.png')
render('Tvoj vrtni dnevnik',A+'/feature-graphic-sl-1024x500.png')
print('en/de/sl re-rendered from base')
