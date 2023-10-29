if vim.g.loaded_3d then
  return
end

vim.g.loaded_3d = true

vim.api.nvim_create_user_command('Cube', function()
  require('3danimation.cube')
end, {})

vim.api.nvim_create_user_command('Donut', function()
  require('3danimation.donut')
end, {})
