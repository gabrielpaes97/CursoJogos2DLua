-- Programa Principal

-- Apelidos
local LG = love.graphics -- metodos de renderizacao
local LK = love.keyboard -- metodos de controle do teclado

--variaveis globais
--imgPlayer = nil -- nil eh a variavel nulo
player = {posx = 0 , posX = 0, veloc = 250, img = nil}

--Timer para controle de tiros
shot = true
maxshot = 0.2
timeshot = maxshot

-- estrutura para controle de tiros
imgshot = nil
shots = {}

--timer para controle dos inimigos
dtMaxEnemy = 0.4
dtAtualEnemy = dtMaxEnemy
mergEnemy = 10

 -- estrutura para controle dos inimigos
imgEnemy = nil
enemys= {}

Vivo = true
Pontos = 0

function love.load() -- Responsavel pelo carregamento dos assets
  --imgPlayer = LG.newImage("Nave.png") -- carrega uma imagem para o jogador
  fundo = LG.newImage("Espaco.png") -- carrega fundo da fase
  
  player.img = LG.newImage("Nave.png")
  meioW = ((LG.getWidth()/2) - (player.img:getWidth()/ 2))
  meioH = ((LG.getHeight()/2) - (player.img:getHeight()/2))
  player.posx = meioH
  player.posy = meioW
  
  imgshot = LG.newImage("projetil.png")
  
  imgEnemy = LG.newImage("Nave-Inimiga.png")
  mergEnemy = imgEnemy:getWidth() / 2
end

function love.draw() -- Responsavel pela renderizacao (padrao 60 fps)
  LG.draw(fundo, 0, 0)
  if(Vivo)then
    LG.draw(player.img, player.posx, player.posy) -- insere a imagen do player passando as cordenadas X e Y do plano cartesiano
  else
    LG.print("Game Over, reinicie o jogo apertando a tecla R", LG.getWidth() / 2 - 50, LG.getHeight() / 2 - 10)
  end
  for i, proj in ipairs(shots) do -- atualizacao dos disparos executados
    LG.draw(proj.img, proj.x, proj.y)
  end  
  --atualizacao dos inimigos
  for i, atual in ipairs(enemys) do
    LG.draw(atual.img, atual.x, atual.y)
  end
end


function love.update(dt) -- Responsavel pelas interacoes com o tempo (animacao, input do teclado)
  for i , atual in ipairs(enemys) do--verifcacao de colisaoes
    for j, proj in ipairs(shots)do--inimigos com disparos
      if(verColisao(atual.x, atual.y, atual.img:getWidth(), atual.img:getHeight(), proj.x, proj.y, proj.img:getWidth(), proj.img:getHeight())) then
        table.remove(enemys, i)
        table.remove(enemys, j)
        Pontos = Pontos + 10
      end
    end
    if(verColisao(atual.x, atual.y, atual.img:getWidth(), atual.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())) then
      table.remove(enemys, i)
      Vivo = false
    end
  end
  if(LK.isDown('left','a'))then
    if(player.posx > 0) then
      player.posx = player.posx - (player.veloc * dt)
      end
    
  elseif(LK.isDown('right','d'))then
    if(player.posx < (LG.getWidth() - player.img:getWidth())) then
      player.posx = player.posx + (player.veloc * dt)
      end
  end
  
  if(LK.isDown('up','w'))then
    if(player.posy > 0) then
      player.posy = player.posy - (player.veloc * dt)
      end
  elseif(LK.isDown('down','s'))then
    if(player.posy < (LG.getHeight() - player.img:getHeight())) then
      player.posy = player.posy + (player.veloc * dt)
    end
  end
  
  timeshot = timeshot - (1 * dt) -- temporizacao dos tiros
  if(timeshot < 0)then
    shot = true
  end
  
  if(LK.isDown('space') and shot)then -- controle dos tiros
    nvShot = {
      x = (player.posx + player.img:getWidth()/2),
      y = player.posy,
      img = imgshot
    }
    table.insert(shots, nvShot)
    shot = false
    timeshot = maxshot
  end
  for i, proj in ipairs(shots) do -- atualizacao da posicao dos projetos
      proj.y = proj.y - (250 * dt)
    if (proj.y < 0) then  -- condicao para remover os projeteis da tela
        table.remove(shots, i)
    end
  end
  
  dtAtualEnemy = dtAtualEnemy - (1 * dt)-- temporizacao dos inimigos
  if(dtAtualEnemy < 0)then
    dtAtualEnemy = dtMaxEnemy
    posDinamic = math.random(10 + mergEnemy, (LG.getWidth()) - (10 + mergEnemy))
    nvEnemy = {x = posDinamic, y = -10, img = imgEnemy}
    table.insert(enemys, nvEnemy)
  end

  for i, atual in ipairs(enemys) do--movimentacao inimigo
    atual.y = atual.y + (200 * dt)
    if (atual.y > LG.getHeight()) then
      table.remove(enemys, i)
    end
  end
  
  if(not Vivo and LK.isDown('r'))then
    --reiniciar inimigos e disparos
    enemys = {}
    shots = {}
    --reinicia os temporizadores
    timeshot = maxshot
    dtAtualEnemy = dtMaxEnemy
    --reposiciona a nave
    player.posx = meioH
    player.posy = meioW
    -- reseta o placar
    Vivo = true
    Pontos = 0
  end
end
-- funcao personalizada para controle de colisao
-- metodo da Bounding Box
function verColisao(x1, y1, w1, h1, x2, y2, w2, h2)
  return(x2 + w2 >= x1 and x2 <= x1 + w1 and y2 + h2 >= y1 and y2 <= h1 + y1)
end