WPUtils = {}

WPUtils.FromJSON = function(json_str)
  local json = require "JSON"
  local wp_table = json.decode(json_str)
  return WPUtils.FromTable(wp_table)
end

WPUtils.ToJSON = function(wp)
  local json = require "JSON"
  local json_str = json.encode(WPUtils.ToTable(wp))
  return json_str
end

WPUtils.ToTable = function(wp)
  return {
    position = {
      x = wp.position.x,
      y = wp.position.y,
      z = wp.position.z
    },
    angle = {
      x = wp.angle.x,
      y = wp.angle.y,
      z = wp.angle.z,
      w = wp.angle.w
    }
  }
end

WPUtils.FromTable = function(wp_table)
  local position = Vector3(wp_table.position.x, wp_table.position.y, wp_table.position.z)
  local angle = Angle(wp_table.angle.x, wp_table.angle.y, wp_table.angle.z, wp_table.angle.w)

  return {position = position, angle = angle}
end

WPUtils.ToLua = function(waypoints)
  local pos, angle, fst
  local str = "local waypoints = {"
  if #waypoints < 1 then
    fst = true
    for k,wp in pairs(waypoints) do
      if not fst then
        str = str .. ","
      end
      fst = false

      pos = wp.position
      angle = wp.angle
      str = str .. string.format("\n  %s = {\n", k)
      str = str .. string.format("    position = Vector3(%f, %f, %f),\n", pos.x, pos.y, pos.z)
      str = str .. string.format("    angle = Angle(%f, %f, %f, %f)\n", angle.x, angle.y, angle.z, angle.w)
      str = str .. "  }"
    end
  else
    fst = true
    for _,wp in ipairs(waypoints) do
      if not fst then
        str = str .. ","
      end
      fst = false

      pos = wp.position
      angle = wp.angle
      str = str .. "\n  {\n"
      str = str .. string.format("    position = Vector3(%f, %f, %f),\n", pos.x, pos.y, pos.z)
      str = str .. string.format("    angle = Angle(%f, %f, %f, %f)\n", angle.x, angle.y, angle.z, angle.w)
      str = str .. "  }"
    end
  end
  str = str .. "\n}\n"
  return str
end
