local cubeWidth = 20
local width, height = vim.o.columns, vim.o.lines
local zBuffer = {}
local buffer = {}
local fill_bg = string.byte(' ')
local distanceFromCam = 100
local horizontalOffset
local K1 = 40

local incrementSpeed = 0.6

local x, y, z
local ooz
local xp, yp
local idx

local function calculateX(i, j, k, A, B, C)
  return j * math.sin(A) * math.sin(B) * math.cos(C)
    - k * math.cos(A) * math.sin(B) * math.cos(C)
    + j * math.cos(A) * math.sin(C)
    + k * math.sin(A) * math.sin(C)
    + i * math.cos(B) * math.cos(C)
end

local function calculateY(i, j, k, A, B, C)
  return j * math.cos(A) * math.cos(C)
    + k * math.sin(A) * math.cos(C)
    - j * math.sin(A) * math.sin(B) * math.sin(C)
    + k * math.cos(A) * math.sin(B) * math.sin(C)
    - i * math.cos(B) * math.sin(C)
end

local function calculateZ(i, j, k, A, B)
  return k * math.cos(A) * math.cos(B) - j * math.sin(A) * math.cos(B) + i * math.sin(B)
end

local function calculateForSurface(cubeX, cubeY, cubeZ, ch, A, B, C)
  x = calculateX(cubeX, cubeY, cubeZ, A, B, C)
  y = calculateY(cubeX, cubeY, cubeZ, A, B, C)
  z = calculateZ(cubeX, cubeY, cubeZ, A, B) + distanceFromCam

  ooz = 1 / z

  xp = math.floor(width / 2 + horizontalOffset + K1 * ooz * x * 2)
  yp = math.floor(height / 2 + K1 * ooz * y)

  idx = xp + yp * width
  if idx >= 0 and idx < width * height then
    if ooz > zBuffer[idx] then
      zBuffer[idx] = ooz
      buffer[idx] = ch
    end
  end
end

local function drawCube(A, B, C)
  for i = 1, width * height do
    buffer[i] = string.char(fill_bg)
    zBuffer[i] = 0
  end

  cubeWidth = 20
  horizontalOffset = -2 * cubeWidth
  -- first cube
  for cubeX = -cubeWidth, cubeWidth, incrementSpeed do
    for cubeY = -cubeWidth, cubeWidth, incrementSpeed do
      calculateForSurface(cubeX, cubeY, -cubeWidth, '@', A, B, C)
      calculateForSurface(cubeWidth, cubeY, cubeX, '$', A, B, C)
      calculateForSurface(-cubeWidth, cubeY, -cubeX, '~', A, B, C)
      calculateForSurface(-cubeX, cubeY, cubeWidth, '#', A, B, C)
      calculateForSurface(cubeX, -cubeWidth, -cubeY, ';', A, B, C)
      calculateForSurface(cubeX, cubeWidth, cubeY, '+', A, B, C)
    end
  end

  local lines = {}
  for i = 1, height do
    local line = {}
    for j = 1, width do
      table.insert(line, buffer[(i - 1) * width + j])
    end
    table.insert(lines, table.concat(line))
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local A, B, C = 0, 0, 0

local function animate()
  A = A + 0.05
  B = B + 0.05
  C = C + 0.01

  drawCube(A, B, C)

  vim.defer_fn(animate, 100)
end

drawCube(A, B, C)
animate()
