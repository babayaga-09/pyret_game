use context starter2024

# Main function to start the game
import image as I
import reactors as R

# Position and world data structures
data Posn:
  | posn(x, y)
end


data World:
  | world(p :: Posn, b :: Posn, f :: Number, c :: Posn, bomb :: Posn)
end


# Constants for game settings
AIRPLANE-URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1qvTpeD4ASQPIO3tQE7CrCW3IMqxZG6ui"
AIRPLANE = I.image-url(AIRPLANE-URL)

BALLOON-URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1kPdLafuvfaYGSgTCJbw8NTyJcpSpiKHu"
BALLOON = I.image-url(BALLOON-URL)

COIN-URL = "https://code.pyret.org/shared-image-contents?sharedImageId=15AjUB_GBNf_Och_OcX-ojdOaSggtfnye"
COIN = I.image-url(COIN-URL)

GAMEOVER-URL = "https://code.pyret.org/shared-image-contents?sharedImageId=12zWgqOtT6gsWSUbZNCOA76CxXefzfBs6"
GAMEOVER = I.image-url(GAMEOVER-URL)
BOMB-URL = "https://code.pyret.org/shared-image-contents?sharedImageId=1Duq2RgtHHyDxlwM9bmaN_88OECvecrD4"
BOMB = I.image-url(BOMB-URL)
BOMB-Y-MOVE = 7
# Constants for game settings
WIDTH = 800
HEIGHT = 500
AIRPLANE-X-MOVE = 10
AIRPLANE-Y-MOVE = 3
BALLOON-Y-MOVE = -5
KEY-DISTANCE = 10

# Scene setup with black background
BACKGROUND = I.rectangle(WIDTH, HEIGHT, "solid", "black")

# Move airplane horizontally with wrapping behavior
fun move-airplane-wrapping-x-on-tick(x):
  num-modulo(x + AIRPLANE-X-MOVE, WIDTH)
end

# Check collision
fun collision(p1, p2, threshold):
  num-sqrt(((p1.x - p2.x) * (p1.x - p2.x)) + ((p1.y - p2.y) * (p1.y - p2.y))) < threshold
end

# Move airplane vertically
fun move-airplane-y-on-tick(y):
  y + AIRPLANE-Y-MOVE
end
fun move-bomb-y-on-tick(bomb):
  if bomb.y > HEIGHT:
    posn(num-random(WIDTH), 0)  # Reset the bomb to the top at a random x position
  else:
    posn(bomb.x, bomb.y + BOMB-Y-MOVE)
  end
end

# Move balloon vertically
fun move-balloon-y-on-tick(b):
  if b.y < 0: posn(b.x, HEIGHT) else: posn(b.x, b.y + BALLOON-Y-MOVE)
  end
end

fun move-coin-x-on-tick(c):
  if c.x < 0:
    posn(WIDTH, num-random(HEIGHT))  # Reset the coin to a random position
  else:
    posn(c.x - 5 , c.y )  # Move the coin leftwards
  end
end

# Place airplane, balloon, and coin on the scene
fun place-airplane-xy(w :: World):
  I.place-image(
    I.text("Fuel: " + num-to-string(w.f), 20, "white"), 50, 20,
    I.place-image(
      AIRPLANE, w.p.x, w.p.y,
      I.place-image(
        BALLOON, w.b.x, w.b.y,
        I.place-image(
          COIN, w.c.x, w.c.y,
          I.place-image(BOMB, w.bomb.x, w.bomb.y, BACKGROUND)))))
end


fun collect-coin(w :: World):
  if distance(w.p, w.c) < 200:
    world(w.p, w.b, w.f + 50, posn(WIDTH, num-random(HEIGHT)), w.bomb)  # Add points and reset coin
  else:
    w  # Return unchanged world
  end
end

fun to-draw(w :: World):
  if game-ends(w):
    GAMEOVER  # Display the game over wallpaper
  else:
    place-airplane-xy(w)  # Display the regular game scene
  end
end


# Move airplane and balloon on each tick
fun move-airplane-xy-on-tick(w :: World):
  collect-coin(world(
    posn(move-airplane-wrapping-x-on-tick(w.p.x), move-airplane-y-on-tick(w.p.y)),
    move-balloon-y-on-tick(w.b),
    w.f,
    move-coin-x-on-tick(w.c),
    move-bomb-y-on-tick(w.bomb)))
end
# Handle key presses to move the airplane vertically
fun alter-airplane-y-on-key(w :: World, key):
  ask:
    | key == "up" then:
      if w.f > 0:
        world(posn(w.p.x, w.p.y - KEY-DISTANCE), w.b, w.f - 1, w.c, w.bomb)
      else:
        w
      end
    | key == "down" then:
      world(posn(w.p.x, w.p.y + KEY-DISTANCE), w.b, w.f - 1, w.c, w.bomb)
    | otherwise: w
  end
end
# Check if the game ends (only when the airplane hits the balloon)
fun game-ends(w :: World):
  ask:
    | distance(w.p, w.b) < 75 then: true  # Collision with balloon
    | distance(w.p, w.bomb) < 50 then: true  # Collision with bomb
    | otherwise: false
  end
end

# Calculate the distance between two positions
fun distance(p1, p2):
  num-sqrt((p1.x - p2.x) * (p1.x - p2.x) ) + ((p1.y - p2.y) * (p1.y - p2.y))
end
# Initial world state with coin's position
INIT-POS = world(posn(0, 0), posn(600, 300), 100, posn(WIDTH, num-random(HEIGHT)), posn(num-random(WIDTH), 0))
# Run the animation
anim = reactor:
  init: INIT-POS,
  on-tick: move-airplane-xy-on-tick,
  on-key: alter-airplane-y-on-key,
  to-draw: to-draw,  # Use the updated to-draw function
  stop-when: game-ends
end

R.interact(anim)