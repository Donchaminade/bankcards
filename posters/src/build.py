"""Génère les affiches LinkedIn de BankCards (HTML/CSS -> Playwright, qualité 2x)."""
import asyncio, random, pathlib
from playwright.async_api import async_playwright

SRC = pathlib.Path(__file__).parent
OUT = SRC.parent

CSS = """
@font-face{font-family:Manrope;src:url(Manrope-400.ttf);font-weight:400}
@font-face{font-family:Manrope;src:url(Manrope-500.ttf);font-weight:500}
@font-face{font-family:Manrope;src:url(Manrope-600.ttf);font-weight:600}
@font-face{font-family:Manrope;src:url(Manrope-700.ttf);font-weight:700}
@font-face{font-family:Manrope;src:url(Manrope-800.ttf);font-weight:800}
@font-face{font-family:Playfair;src:url(Playfair-700.ttf);font-weight:700}
@font-face{font-family:Playfair;src:url(Playfair-Italic.ttf);font-style:italic;font-weight:400}
*{box-sizing:border-box;margin:0;padding:0}
html,body{background:#07090F}
.poster{position:relative;overflow:hidden;font-family:Manrope;color:#fff;
  background:radial-gradient(120% 80% at 75% 20%,#16357A 0%,#0A1F44 45%,#07090F 100%);page-break-after:always}
.poster:last-child{page-break-after:auto}
.grain{position:absolute;inset:0;background:radial-gradient(60% 40% at 15% 95%,rgba(212,175,55,.10),transparent 70%);pointer-events:none}
.spark{position:absolute;pointer-events:none}
.eyebrow{font-weight:700;letter-spacing:.32em;font-size:15px;color:#E9C766;text-transform:uppercase}
.h1{font-family:Playfair;font-weight:700;line-height:1.08;letter-spacing:-.01em}
.h1 em{font-style:italic;font-weight:400;background:linear-gradient(100deg,#9C7A1E,#D4AF37 35%,#F5D77A 60%,#D4AF37);
  -webkit-background-clip:text;background-clip:text;color:transparent;padding-right:.05em}
.sub{color:rgba(255,255,255,.72);font-weight:500;line-height:1.5}
.rule{height:2px;width:64px;background:linear-gradient(90deg,#D4AF37,#F5D77A);border-radius:2px}
.brand{display:flex;align-items:center;gap:12px;font-weight:800;font-size:22px;letter-spacing:-.01em}
.mark{width:22px;height:22px;transform:rotate(45deg);border-radius:5px;background:linear-gradient(135deg,#9C7A1E,#D4AF37 40%,#F5D77A 65%,#D4AF37);
  box-shadow:0 0 14px rgba(212,175,55,.55);position:relative}
.mark:after{content:"";position:absolute;inset:7px;background:#0A1F44;border-radius:2px}
.foot{position:absolute;left:72px;right:72px;bottom:52px;display:flex;align-items:center;justify-content:space-between;
  font-size:17px;color:rgba(255,255,255,.7);font-weight:600}
.foot .url{color:#F5D77A}
.phone{position:relative;border-radius:52px;padding:11px;background:#050608;border:2px solid rgba(212,175,55,.55);
  box-shadow:0 40px 80px rgba(0,0,0,.55),0 0 0 1px rgba(255,255,255,.04) inset,0 0 60px rgba(212,175,55,.10)}
.phone .screen{position:relative;border-radius:42px;overflow:hidden;background:var(--top,#F6F7FB)}
.phone .bar{height:var(--barh,34px);display:flex;align-items:center;justify-content:space-between;padding:0 30px;
  font-size:13px;font-weight:700;color:var(--ink,#07090F)}
.phone .island{position:absolute;top:9px;left:50%;transform:translateX(-50%);width:31%;height:22px;border-radius:12px;background:#000}
.phone .icons{display:flex;gap:4px;align-items:center}
.phone .icons i{display:block;width:15px;height:8px;border-radius:2px;background:currentColor;opacity:.85}
.phone .icons i:first-child{width:10px}
.phone img{display:block;width:100%}
.badge{display:inline-flex;align-items:center;justify-content:center;width:44px;height:44px;border-radius:50%;
  border:1.5px solid rgba(212,175,55,.7);color:#F5D77A;font-weight:800;font-size:16px;background:rgba(10,31,68,.6)}
.chip{display:inline-flex;align-items:center;gap:8px;padding:9px 16px;border-radius:40px;border:1px solid rgba(212,175,55,.45);
  color:#F5D77A;font-weight:700;font-size:15px;background:rgba(255,255,255,.04)}
.card-glass{background:rgba(255,255,255,.045);border:1px solid rgba(255,255,255,.09);border-radius:24px}
"""

DARK = {'home': ('#0E2962', '#fff'), 'receipt': ('#0B1329', '#fff')}

def phone(img, width, kind='light', extra_style=''):
    top, ink = DARK.get(kind, ('#F6F7FB', '#07090F'))
    barh = round(width * 0.087)
    return (f'<div class="phone" style="width:{width}px;{extra_style}">'
            f'<div class="screen" style="--top:{top};--ink:{ink};--barh:{barh}px">'
            f'<div class="bar"><span>12:03</span><span class="icons"><i></i><i></i></span></div>'
            f'<div class="island"></div><img src="img/{img}"></div></div>')

def sparkles(w, h, n, seed, avoid=()):
    r = random.Random(seed); out = []
    while len(out) < n:
        x, y = r.uniform(0, w), r.uniform(0, h); s = r.uniform(5, 15) * (1.6 if r.random() < .12 else 1)
        if any(x0 - 20 < x < x1 + 20 and y0 - 20 < y < y1 + 20 for x0, y0, x1, y1 in avoid):
            continue
        a = r.uniform(.25, .85); col = r.choice(['#F5D77A', '#D4AF37', '#FFF4CC', '#FFFFFF'])
        out.append(f'<svg class="spark" style="left:{x-s:.0f}px;top:{y-s:.0f}px;opacity:{a:.2f}" width="{2*s:.0f}" height="{2*s:.0f}" viewBox="-10 -10 20 20">'
                   f'<circle r="5" fill="{col}" opacity=".18"/><path d="M0-10Q0 0 10 0Q0 0 0 10Q0 0-10 0Q0 0 0-10Z" fill="{col}"/></svg>')
    return ''.join(out)

def poster(w, h, body, seed, n=30, avoid=None):
    if avoid is None:
        avoid = [(60, 50, w - 60, 480)] if w == 1080 else [(40, 40, 700, 600)]
    avoid = list(avoid) + [(0, h - 110, w, h)]  # pied de page
    return f'<section class="poster" style="width:{w}px;height:{h}px"><div class="grain"></div>{sparkles(w,h,n,seed,avoid)}{body}</section>'

def foot(left='', right='bankcards-flutter.vercel.app'):
    return (f'<div class="foot"><div class="brand"><span class="mark"></span>BankCards</div>'
            f'<div>{left}</div><div class="url">{right}</div></div>')

# ---------- Affiche principale 1080x1350 ----------
main = poster(1080, 1350, f'''
<div style="position:absolute;left:72px;right:72px;top:76px">
  <div class="eyebrow">Étude de cas · UI mobile · Flutter</div>
  <div class="h1" style="font-size:74px;margin-top:26px">L'UI <em>premium</em><br>au service de l'expérience<br>utilisateur.</div>
  <div class="sub" style="font-size:22px;margin-top:24px;max-width:860px">BankCards : un parcours de commande de carte bancaire pensé pour inspirer confiance, du choix de la carte jusqu'au reçu.</div>
</div>
<div style="position:absolute;left:0;right:0;top:520px;height:730px">
  <div style="position:absolute;left:84px;top:100px;transform:rotate(-7deg);transform-origin:bottom right">{phone('confirm.png',270)}</div>
  <div style="position:absolute;right:84px;top:100px;transform:rotate(7deg);transform-origin:bottom left">{phone('placed.png',270)}</div>
  <div style="position:absolute;left:50%;top:0;transform:translateX(-50%);z-index:2">{phone('picker_gold.png',328)}</div>
</div>
{foot('Flutter · Dart')}
''', 1)

# ---------- Bannière 1200x627 ----------
banner = poster(1200, 627, f'''
<div style="position:absolute;left:64px;top:64px;width:600px">
  <div class="eyebrow" style="font-size:13px">Étude de cas · UI mobile · Flutter</div>
  <div class="h1" style="font-size:54px;margin-top:20px">L'UI <em>premium</em> au service de l'expérience utilisateur.</div>
  <div class="sub" style="font-size:18px;margin-top:20px;max-width:540px">BankCards : choisir sa carte, confirmer, payer et recevoir son reçu, dans un parcours clair et soigné.</div>
  <div style="display:flex;gap:10px;margin-top:28px"><span class="chip">5 cartes, 5 finitions</span><span class="chip">Animations Hero 3D</span></div>
</div>
<div style="position:absolute;left:64px;bottom:44px;display:flex;gap:28px;align-items:center;font-size:15px;font-weight:600;color:rgba(255,255,255,.7)">
  <div class="brand" style="font-size:19px;color:#fff"><span class="mark" style="width:18px;height:18px"></span>BankCards</div>
  <span style="color:#F5D77A">bankcards-flutter.vercel.app</span>
</div>
<div style="position:absolute;right:250px;top:62px;transform:rotate(-6deg)">{phone('confirm.png',226)}</div>
<div style="position:absolute;right:60px;top:40px;z-index:2">{phone('picker_gold.png',240)}</div>
''', 2, 26)

# ---------- Carrousel ----------
def head(num, title, sub, top=76, size=64):
    return (f'<div style="position:absolute;left:72px;right:72px;top:{top}px">'
            f'<div class="eyebrow">{num:02d} / 05</div>'
            f'<div class="h1" style="font-size:{size}px;margin-top:22px">{title}</div>'
            f'<div class="rule" style="margin-top:26px"></div>'
            f'<div class="sub" style="font-size:22px;margin-top:22px;max-width:900px">{sub}</div></div>')

s1 = poster(1080, 1350, f'''
<div style="position:absolute;left:72px;right:72px;top:80px">
  <div class="eyebrow">BankCards · Étude de cas</div>
  <div class="h1" style="font-size:72px;margin-top:26px">BankCards : l'UI <em>premium</em> au service de l'expérience utilisateur</div>
  <div class="sub" style="font-size:22px;margin-top:24px;max-width:880px">Comment une interface soignée transforme une simple commande de carte bancaire en un moment de confiance.</div>
</div>
<div style="position:absolute;left:0;right:0;top:540px;height:720px">
  <div style="position:absolute;left:150px;top:60px;transform:rotate(-6deg)">{phone('home.png',300,'home')}</div>
  <div style="position:absolute;right:150px;top:0;z-index:2;transform:rotate(4deg)">{phone('picker_infinite.png',310)}</div>
</div>
{foot('Faites défiler &rarr;', '01 / 05')}
''', 11)

steps = [('picker_gold.png', 'Choisir', 'Un swipe entre cinq cartes, prix et finition visibles d’un coup d’œil.'),
         ('confirm.png', 'Confirmer', 'Un récapitulatif lisible et un bouton principal toujours accessible.'),
         ('placed.png', 'Payer', 'Un retour immédiat : la carte se pose, la validation s’affiche.'),
         ('receipt.png', 'Recevoir', 'Le reçu s’imprime ligne par ligne, tamponné « PAYÉ ».')]
cols = ''.join(f'''<div style="width:222px">
  <div style="display:flex;align-items:center;gap:12px;margin-bottom:18px"><span class="badge">{i+1:02d}</span><span style="font-weight:800;font-size:22px">{t}</span></div>
  {phone(img,222,'receipt' if img=='receipt.png' else 'light')}
  <div class="sub" style="font-size:16.5px;margin-top:20px;line-height:1.45">{d}</div></div>''' for i,(img,t,d) in enumerate(steps))
s2 = poster(1080, 1350, head(2, 'Un parcours <em>clair</em>', 'Quatre étapes, une seule décision par écran. L’utilisateur sait toujours où il en est et ce qui l’attend.') + f'''
<div style="position:absolute;left:72px;right:72px;top:470px;display:flex;justify-content:space-between">{cols}</div>
<div class="card-glass" style="position:absolute;left:72px;right:72px;bottom:120px;padding:24px 30px;font-size:19px;font-weight:600;color:rgba(255,255,255,.85)">
  Le bouton principal reste fixé en bas, au-dessus de la zone de sécurité : rien n’est caché, sur aucun écran.</div>
{foot('', '02 / 05')}''', 12)

anims = [('Le mouvement oriente', 'La carte se soulève et pivote de 90° vers l’écran de choix : on comprend instantanément d’où elle vient.'),
         ('La profondeur guide le choix', 'Pendant le swipe, chaque carte s’incline en 3D ; le titre, le prix et le halo suivent le geste.'),
         ('Chaque action a une réponse', 'Le bouton se transforme pendant le paiement, la carte se pose sur le terminal, puis la validation se dessine.'),
         ('Une conclusion rassurante', 'Le reçu s’imprime ligne par ligne et le tampon « PAYÉ » vient clore le parcours.')]
items = ''.join(f'''<div style="display:flex;gap:18px;margin-bottom:46px"><span class="badge" style="flex:none">{i+1}</span>
  <div><div style="font-weight:800;font-size:25px">{t}</div><div class="sub" style="font-size:19px;margin-top:8px">{d}</div></div></div>''' for i,(t,d) in enumerate(anims))
s3 = poster(1080, 1350, head(3, 'Des animations qui ont du <em>sens</em>', 'Ici, l’animation n’est pas décorative : elle explique ce qui se passe et rassure à chaque étape.') + f'''
<div style="position:absolute;left:72px;top:500px;width:490px">{items}</div>
<div style="position:absolute;right:56px;top:500px;width:400px;height:720px">
  <div style="position:absolute;right:130px;top:10px;transform:rotate(-5deg)">{phone('picker_world.png',262)}</div>
  <div style="position:absolute;right:0;top:130px;z-index:2;transform:rotate(4deg)">{phone('placed.png',262)}</div>
</div>
{foot('', '03 / 05')}''', 13)

cards = [('classic', 'Visa Classic', 'PVC recyclé, finition brillante · 15 000 FCFA'),
         ('world', 'Mastercard World', 'Polycarbonate bleu nuit · 35 000 FCFA'),
         ('gold', 'Visa Gold', 'Métal doré brossé · 60 000 FCFA'),
         ('platinum', 'Visa Platinum', 'Acier brossé · 120 000 FCFA'),
         ('infinite', 'Visa Infinite', 'Métal noir et or · 250 000 FCFA')]
off = 128
stack = ''.join(f'<img src="img/card_{c}.png" style="position:absolute;left:0;top:{i*off}px;width:540px;border-radius:30px;box-shadow:0 -12px 40px rgba(0,0,0,.45)">' for i,(c,_,_) in enumerate(cards))
labels = ''.join(f'''<div style="position:absolute;left:0;top:{i*off+22}px">
  <div style="font-weight:800;font-size:23px">{n}</div><div class="sub" style="font-size:16.5px;margin-top:4px">{d}</div></div>''' for i,(_,n,d) in enumerate(cards))
s4 = poster(1080, 1350, head(4, '5 cartes, 5 <em>finitions</em>', 'Chaque niveau de carte a sa matière : brillant, métal brossé, acier ou noir et or. Un reflet doré balaie la surface.') + f'''
<div style="position:absolute;left:72px;top:410px;width:540px;height:860px">{stack}</div>
<div style="position:absolute;left:650px;right:56px;top:410px;height:860px">{labels}</div>
{foot('', '04 / 05')}''', 14, 28)

s5 = poster(1080, 1350, head(5, 'Démo et <em>code</em>', 'Le projet est ouvert : testez le parcours dans le navigateur, installez l’app ou explorez le code.') + f'''
<div style="position:absolute;left:72px;top:500px">{phone('receipt.png',300,'receipt')}</div>
<div style="position:absolute;left:440px;right:72px;top:500px;display:flex;flex-direction:column;gap:22px">
  <div class="card-glass" style="padding:24px;display:flex;gap:22px;align-items:center">
    <img src="img/qr-demo.png" style="width:118px;border-radius:12px">
    <div><div class="eyebrow" style="font-size:12px">Démo web</div><div style="font-weight:800;font-size:22px;margin-top:8px;color:#F5D77A">bankcards-flutter.vercel.app</div></div></div>
  <div class="card-glass" style="padding:24px;display:flex;gap:22px;align-items:center">
    <img src="img/qr-code.png" style="width:118px;border-radius:12px">
    <div><div class="eyebrow" style="font-size:12px">Code source</div><div style="font-weight:800;font-size:20px;margin-top:8px;color:#F5D77A">github.com/Donchaminade/<br>bankcards</div></div></div>
  <div class="card-glass" style="padding:22px 24px;font-size:17.5px;line-height:1.55;color:rgba(255,255,255,.82)">
    <b style="color:#fff">Applications</b> · APK Android et IPA iPhone dans la Release du dépôt.<br>
    <b style="color:#fff">Stack</b> · Flutter, Dart, Hero, Matrix4, CustomPainter. Illustrations 100 % codées.</div>
  <div class="sub" style="font-size:15.5px">Inspiré de la démo « Digital Wallet » de Santhosh S.<br>Une étoile ou un fork est toujours apprécié.</div>
</div>
{foot('', '05 / 05')}''', 15)

def page(sections, w, h):
    return (f'<!doctype html><html><head><meta charset="utf-8"><style>{CSS}@page{{size:{w}px {h}px;margin:0}}</style></head>'
            f'<body>{"".join(sections)}</body></html>')

async def render():
    jobs = [('bankcards-affiche-1080x1350', [main], 1080, 1350), ('bankcards-banniere-1200x627', [banner], 1200, 627)]
    slides = [s1, s2, s3, s4, s5]
    for i, s in enumerate(slides, 1):
        jobs.append((f'bankcards-carrousel-{i:02d}', [s], 1080, 1350))
    async with async_playwright() as p:
        b = await p.chromium.launch()
        for name, secs, w, h in jobs:
            f = SRC / f'{name}.html'; f.write_text(page(secs, w, h), encoding='utf-8')
            pg = await b.new_page(viewport={'width': w, 'height': h}, device_scale_factor=2)
            await pg.goto(f.as_uri()); await pg.wait_for_load_state('networkidle'); await pg.evaluate('document.fonts.ready')
            await pg.screenshot(path=str(OUT / f'{name}.png'), clip={'x': 0, 'y': 0, 'width': w, 'height': h})
            await pg.close()
        f = SRC / 'carrousel.html'; f.write_text(page(slides, 1080, 1350), encoding='utf-8')
        pg = await b.new_page(viewport={'width': 1080, 'height': 1350})
        await pg.goto(f.as_uri()); await pg.wait_for_load_state('networkidle'); await pg.evaluate('document.fonts.ready')
        await pg.close()
        await b.close()

asyncio.run(render())

# PDF du carrousel (document LinkedIn) : assemblé à partir des PNG, rendu identique.
from PIL import Image
_slides = [Image.open(OUT / f'bankcards-carrousel-{i:02d}.png').convert('RGB') for i in range(1, 6)]
_slides[0].save(OUT / 'bankcards-carrousel-linkedin.pdf', save_all=True, append_images=_slides[1:], resolution=192, quality=92)
print('ok')
