class('NamedWP_Database')

function NamedWP_Database:__init()
  SQL:Execute( "create table if not exists named_waypoints (id VARCHAR UNIQUE, waypoint VARCHAR)" )
end

function NamedWP_Database:Load()
  local qry = SQL:Query( "select id, waypoint from named_waypoints" )
  local results = qry:Execute()
  local waypoints = {}

  for _,wp_json in pairs(results) do
    local wp = WPUtils.FromJSON(wp_json.waypoint)
    waypoints[wp_json.id] = wp
  end

  return waypoints
end

function NamedWP_Database:Add(name, wp)
  wp_json = WPUtils.ToJSON(wp)
  local qry = SQL:Query( "insert into named_waypoints (id, waypoint) values (?, ?)" )
  qry:Bind( 1, name )
  qry:Bind( 2, wp_json )
  return qry:Execute()
end

function NamedWP_Database:Update(name, wp)
  wp_json = WPUtils.ToJSON(wp)
  local qry = SQL:Query( "update named_waypoints set waypoint = ? where id = ?" )
  qry:Bind( 1, wp_json )
  qry:Bind( 2, name )
  return qry:Execute()
end

function NamedWP_Database:Remove(name)
  local qry = SQL:Query( "delete from named_waypoints where id = ?" )
  qry:Bind( 1, name )
  return qry:Execute()
end
