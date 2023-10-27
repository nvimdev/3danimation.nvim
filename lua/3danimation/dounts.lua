local Theta_spacing = 0.07
local Phi_spacing = 0.02
local a, ba, Main_str, z, b
a = 0
ba = 0

Main_str = { '.', ',', '-', '~', ':', ';', '=', '!', '*', '#', '$', '@' }
local bufnr = vim.api.nvim_get_current_buf()
z = {}
b = {}
local function updateDonut()
  local i, j
  j = 0
  -- Zeros arrays
  for l = 1, 1760 do
    z[l] = 0
  end
  for t = 1, 1760 do
    b[t] = ' '
  end
  -- Calculate the donut
  while j < 6.28 do
    j = j + Theta_spacing
    i = 0
    while i < 6.28 do
      i = i + Phi_spacing

      local c, d, e, f, g, h, D, l, m, n, t, x, y, o, N
      c = math.sin(i)
      l = math.cos(i)
      d = math.cos(j)
      f = math.sin(j)

      e = math.sin(a)
      g = math.cos(a)
      h = d + 2
      D = 1 / (c * h * e + f * g + 5)

      m = math.cos(ba)
      n = math.sin(ba)
      t = c * h * g - f * e

      x = math.floor(40 + 30 * D * (l * h * m - t * n))
      y = math.floor(12 + 15 * D * (l * h * n + t * m))
      o = math.floor(x + 80 * y)
      N = math.floor(8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n))

      if 22 > y and y > 0 and 80 > x and x > 0 and D > z[o + 1] then
        z[o + 1] = D
        if N > 0 then
          b[o + 1] = Main_str[N + 1]
        else
          b[o + 1] = '.'
        end
      end
    end
  end

  -- Format the buffer content with line breaks
  local lines = {}
  local line = ''
  for l = 1, 1760 do
    line = line .. b[l]
    if l % 80 == 0 then
      table.insert(lines, line)
      line = ''
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Increment angles
  a = a + 0.04
  ba = ba + 0.02
end

-- Create a timer to update the donut animation
local timer
timer = vim.uv.new_timer()
timer:start(
  50,
  50,
  vim.schedule_wrap(function()
    updateDonut()
  end)
)
