_addon.name     = 'odoro'
_addon.author   = 'Elidyr'
_addon.version  = '1'
_addon.command  = 'odoro'

texts   = require('texts')
files   = require('files')
packets = require('packets')
require('tables')
require('strings')
require('lists')
require('logger')

-- CHANGE FONT SIZE!
local font_size = 7

local layout    = {pos={x=100, y=100}, colors={text={alpha=255, r=245, g=200, b=20}, bg={alpha=200, r=0, g=0, b=0}, stroke={alpha=255, r=0, g=0, b=0}}, font={name='Lucida Console', size=font_size}, padding=3, stroke_width=1, draggable=true}
local display   = texts.new('', layout)
local f         = files.new('block_list.lua')
if not f:exists() then
    f:write(string.format('return %s', T({}):tovstring()))
end

display:pos(layout.pos.x, layout.pos.y)
display:font(layout.font.name)
display:color(layout.colors.text.r, layout.colors.text.g, layout.colors.text.b)
display:alpha(layout.colors.text.alpha)
display:size(layout.font.size)
display:pad(layout.padding)
display:bg_color(layout.colors.bg.r, layout.colors.bg.g, layout.colors.bg.b)
display:bg_alpha(layout.colors.bg.alpha)
display:stroke_width(layout.stroke_width)
display:stroke_color(layout.colors.stroke.r, layout.colors.stroke.g, layout.colors.stroke.b)
display:stroke_alpha(layout.colors.stroke.alpha)
display:update()

-- PLAYER TO BLOCK.
local block_me = T(dofile(string.format('%sblock_list.lua', windower.addon_path)))
windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)

    if id == 0x00d then
        local packed = packets.parse('incoming', original)

        if packed then
            local mob = windower.ffxi.get_mob_by_id(packed['Player'])
            
            if mob and (block_me):contains(mob.name) and (not packed['Despawn'] or packed['Despawn']) then
                packed['Despawn'] = true
                
                do -- Block yo ass.
                    return packets.build(packed)
                end

            end

        end

    end

end)

windower.register_event('addon command', function(...)
    local a = T{...}
    local c = a[1] or false

    if c then
        c = c:lower()
        
        if c == 'add' and windower.ffxi.get_mob_by_target('t') then
            local target = windower.ffxi.get_mob_by_target('t')

            if target then
                table.insert(block_me, string.format('%s', windower.ffxi.get_mob_by_target('t').name))
                windower.add_to_chat(10, string.format('%s; This account is now completely blocked, bye Felicia!', target.name))

                if f:exists() then
                    f:write(string.format('return %s', T(block_me):tovstring()))
                end
            
            end

        elseif c == 'remove' and a[2] then
            local name = a[2]

            if name then

                for i,v in ipairs(block_me) do

                    if name == v then
                        table.remove(block_me, i)
                        windower.add_to_chat(10, string.format('%s has been removed from black list!', name))

                        if f:exists() then
                            f:write(string.format('return %s', T(block_me):tovstring()))
                        end
                        break
                    
                    end

                end

            end

        elseif c == 'list' then

            if display:visible() then
                display:hide()

            elseif not display:visible() and T(block_me):length() > 0 then
                local update = {}

                for i,v in ipairs(block_me) do

                    if i == 1 then
                        table.insert(update, string.format('%s [ \\cs(150,200,20)Blocked Characters\\cr ] %s\n\nBlocking: \\cs(80,180,220)%s\\cr', (''):rpad(' ', 5), (''):lpad(' ', 5), v))
                    
                    else
                        table.insert(update, string.format('Blocking: %s', v))

                    end

                end
                display:text(table.concat(update, '\n'))
                display:update()
                display:show()

            end                

        end                

    end

end)
