-- Disables the ability to toggle the debug view
RELEASE = true

-- Show debug view or not
DEBUG = false

-- Whether or not to show more detailed debug info
DETAILED_DEBUG = false

-- If hitboxes should be drawn for all objects
DRAW_HITBOXES = false

-- If the hitbox for the player's attack should be shown
DRAW_ATTACKBOX = false

-- Game will not be updated if not running, but debug controls will still work
RUNNING = false

-- The item currently being inspected
ACTIVE_ITEM = nil

-- Dimensions of the game canvas
CANVAS_WIDTH = 240
CANVAS_HEIGHT = 160

-- Scale factor of the game canvas
SCALEX = love.graphics.getWidth() / CANVAS_WIDTH
SCALEY = love.graphics.getHeight() / CANVAS_HEIGHT

-- Dimensions of the tiles in the map
TILE_WIDTH = 16
TILE_HEIGHT = 16
