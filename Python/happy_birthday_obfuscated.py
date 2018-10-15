"""
Title:  Happy Birthday Obfuscation 
Desc:   This silly little script builds, in an unnecessarily convoluted way, a happy birthday message
		Then, using the Opy library, it obfuscates it to make for a fun little delight
			https://github.com/QQuick/Opy
"""


chord_tones = ['a','b','c','d','e','f','g']
f1 = 't' + 'r'
f2 = 'n' + f1[:1]
f1 = f1.capitalize()
pete = lambda x: [yo for yo in chord_tones if yo == 'e']
ctf = pete(30)[0]
f3 = "{}{}{}".format(f1,ctf,f2)

def lN(wwoossuupp):
    """All this needs is a last name    
    Args:
        wwoossuupp (str): we'll figure that out later
    """
    build = "H"
    print(list(locals().keys())[1])
    build += list(locals().keys())[1][5:6]
    build += "w"
    eliza = lambda x: [yo for yo in chord_tones if yo == 'a' or yo == 'd']
    build += eliza(6251)[0]
    build += "r"
    return build + eliza(145)[1]


build_name = f3 + " " + lN(20181012)

print("Happy Birthday"+ " " + build_name + " !!!")