 LARGURA_TELA = 320
 ALTURA_TELA = 480
 MAX_METEOROS = 20
 METEOROS_ATINGIDOS = 0
 NUMERO_METEOROS_OBJETIVO = 10 

function love.load()
    keys = {}
    love.window.setMode(LARGURA_TELA,ALTURA_TELA,{resizable = false})
    love.window.setTitle("14bis vs Meteoros")
    game_over = love.audio.newSource("audios/game_over.wav")
    gameover_img = love.graphics.newImage("imagens/gameover.png")
    vencedor_img = love.graphics.newImage("imagens/vencedor.png")
    vencedor_som = love.audio.newSource("audios/winner.wav")

    math.randomseed(os.time())
    cenario = {
        background = love.graphics.newImage("imagens/background.png"),
        musica = love.audio.newSource("audios/ambiente.wav"),
        draw = function(self)
            love.graphics.draw(self.background,0,0) 
        end,
        tocarMusica = function(self)
          self.musica:setLooping(true)
          self.musica:play()
        end,
        paraMusica = function(self)
            self.musica:stop()
        end
    }

    aviao = {
        image = love.graphics.newImage("imagens/14bis.png"),
        explosao = love.graphics.newImage("imagens/explosao_nave.png"),
        destruicao = love.audio.newSource("audios/destruicao.wav"),
        disparo = love.audio.newSource("audios/disparo.wav"),
        largura = 54,
        altura = 63,
        x = LARGURA_TELA/2 - 64/2,
        y = ALTURA_TELA - 64/2,
        tiros = {},
        destruido = false,
        draw = function(self)
            if self.destruido then
                love.graphics.draw(self.explosao,self.x,self.y)
                self.largura = 67
                self.altura = 67
            else
                love.graphics.draw(self.image,self.x,self.y)
            end
        end,
        somDestruicao = function(self)
            if self.destruido then
                self.destruicao:play()
            end
        end,
        daTiro = function(self)
           self.disparo:play()
           local tiro = {
               image = love.graphics.newImage("imagens/tiro.png"),
               x = self.x + self.largura/2,
               y = self.y,
               largura = 16,
               altura = 16
           }
           table.insert(self.tiros,tiro)
        end,
        moveTiros = function(self)
            for i= #self.tiros,1,-1 do
                if self.tiros[i].y > 0 then
                      self.tiros[i].y = self.tiros[i].y - 1
                else
                    table.remove(self.tiros[i],i)
                end
            end
        end,
        drawTiros = function(self)
             for k,tiro in pairs(self.tiros) do
                 love.graphics.draw(tiro.image,tiro.x,tiro.y)
             end
        end,
        moveLeft = function(self) 
            self.x = self.x-1
        end,
        moveRight = function(self)
            self.x = self.x+1
        end,
        moveUp = function(self)
            self.y = self.y-1
        end,
        moveDown = function(self)
             self.y = self.y+1
        end
    }
    cenario:tocarMusica() 

     movimento = {
        ["left"] = {
            action = function()
                aviao:moveLeft()
                end
            },
       ["right"] = {
            action = function()
                aviao:moveRight()
            end
        },
        ["up"] = {
             action = function()
                aviao:moveUp()
             end   
        },
        ["down"] = {
              action = function()
                aviao:moveDown()
             end      
        },
        [" "] = {
            action = function()
                aviao:daTiro()
            end
        } 
    }     
end

function temColisao(X1,Y1,L1,A1,X2,Y2,L2,A2)
   return X2 < X1 + L1 and
          X1 < X2 + L2 and
          Y1 < Y2 + A2 and
          Y2 < Y1 + A1
end

meteoros = {}

function removeMeteoros()
    for i = #meteoros, 1,-1 do
        if meteoros[i].y > ALTURA_TELA then
            table.remove(meteoros,i)
        end    
    end
end

function criaMeteoro()
    meteoro = {
        image = love.graphics.newImage("imagens/meteoro.png"),
        x = math.random(LARGURA_TELA),
        y = -70,
        largura = 50,
        altura = 44,
        peso = math.random(3),
        deslocamento_horizontal = math.random(-1,1),
        draw = function(self)
            love.graphics.draw(self.image,self.x,self.y)
        end,
        moveDown = function(self)
             self.y = self.y+self.peso
             self.x = self.x + self.deslocamento_horizontal
        end
    }
    table.insert(meteoros,meteoro)
end

function moveMeteoro()
    for k,meteoro in pairs(meteoros) do
        meteoro:moveDown()
    end
end

function moveAviao()
    if love.keyboard.isDown('up') then
        aviao:moveUp()     
   end
   if love.keyboard.isDown('down') then
       aviao:moveDown()
   end
   if love.keyboard.isDown('left') then
        aviao:moveLeft()
   end
   if love.keyboard.isDown('right') then
       aviao:moveRight() 
   end
end

function trocaMusica()
    cenario:paraMusica()
    game_over:play()
end

function checaColisaoComAviao()
    for k,meteoro in pairs(meteoros) do
        if temColisao(meteoro.x,meteoro.y,meteoro.largura,meteoro.altura,aviao.x,aviao.y,aviao.largura,aviao.altura) then
            aviao.destruido = true
            aviao:somDestruicao()
            FIM_JOGO = true
        end
    end
end

function checaColisaoComTiros()
    for i = #aviao.tiros,1,-1 do
        for j = #meteoros,1,-1 do
            if temColisao(aviao.tiros[i].x,aviao.tiros[i].y,aviao.tiros[i].largura,aviao.tiros[i].altura,
            meteoros[j].x,meteoros[j].y,meteoros[j].largura,meteoros[j].altura) then
                METEOROS_ATINGIDOS = METEOROS_ATINGIDOS + 1 
                table.remove(aviao.tiros,i)
                table.remove(meteoros,j)
                break
            end
        end    
    end
end

function checaColisoes()
    checaColisaoComAviao()
    checaColisaoComTiros()        
end

function checaObjetivoConcluido()
    if METEOROS_ATINGIDOS >= NUMERO_METEOROS_OBJETIVO then
        cenario:paraMusica()
        VENCEDOR = true
        vencedor_som:play()
    end 
end

function love.update(dt)
   if not FIM_JOGO and not VENCEDOR then
    if love.keyboard.isDown('left','right','up','down') then
            moveAviao()
    end

        removeMeteoros()
    if #meteoros < MAX_METEOROS then
            criaMeteoro()
    end
    aviao:moveTiros()
    moveMeteoro()
    checaColisoes()
    checaObjetivoConcluido()
   end 
   
   -- for i=1,#keys do
   --       movimento[keys[i]].action()
   -- end
end

function love.keypressed(tecla) 
    table.insert(keys,tecla)
    if tecla == "escape" then
           love.event.quit()
   elseif tecla == " " then
           aviao:daTiro()  
    end
end

function love.keyreleased(tecla)
    keys = {}
end

function love.draw()
    cenario:draw()
    aviao:draw()
    love.graphics.print("Meteoros restantes "..NUMERO_METEOROS_OBJETIVO-METEOROS_ATINGIDOS,0,0)
    for k,meteoro in pairs(meteoros) do
        meteoro:draw()
    end
    aviao:drawTiros()

    if FIM_JOGO then
        love.graphics.draw(gameover_img,LARGURA_TELA/2 -gameover_img:getWidth()/2,ALTURA_TELA/2 - gameover_img:getHeight()/2);
    end

    if VENCEDOR then
        love.graphics.draw(vencedor_img,LARGURA_TELA/2 -vencedor_img:getWidth()/2,ALTURA_TELA/2 - vencedor_img:getHeight()/2);
    end
end