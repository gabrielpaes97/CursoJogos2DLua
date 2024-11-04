-- Programa Principal

-- Apelidos
local LG = love.graphics -- métodos de renderização
local LK = love.keyboard -- métodos de controle do teclado

-- Variáveis Globais
--imgJogador = nil
jogador = { posx = 0, posy = 0, veloc = 600, img = nil}

-- Timer para controle de tiros
podeTirar = true
atiraMax = 0.2
tempoTiro = atiraMax
-- Estrutura para controlar os tiros
imgProjetil = nil
disparos = {}

-- Timer para controle dos inimigos
dtMaxCriaInimigo = 0.8
dtAtualInimigo = dtMaxCriaInimigo
margemInimigo = 10

-- Estrutura para controle dos inimigos
imgInimigo = nil
inimigos = {}

-- Controle de Fim de Jogo e Pontuação
Vivo = true
Pontos = 0


-- Responsável pela carga dos insumos (assets)
function love.load()
  --imgJogador = LG.newImage('Nave.png') -- carga da imagem
  fundo = LG.newImage("Espaco.png") -- fundo do jogo
  jogador.img = LG.newImage("Nave.png") -- jogador
  meioh = (LG.getWidth() - jogador.img:getWidth()) / 2
  --meiov = (LG.getHeight() - jogador.img:getHeight()) / 2
  meiov = LG.getHeight() - jogador.img:getHeight()
  jogador.posx = meioh
  jogador.posy =  meiov
  imgProjetil = LG.newImage("projetil.png")
  imgInimigo = LG.newImage("Nave-Inimiga.png")
  margemInimigo = imgInimigo:getWidth() / 2
  Tiro = love.audio.newSource("tiro.wav", "static")
end

-- Responsável pela renderização na tela (fps)
function love.draw()
  LG.draw(fundo, 0, 0)
  -- Desenhar a imagem passando o arquivo e (x, y)
  if (Vivo) then
    LG.draw(jogador.img, jogador.posx, jogador.posy)
  else
    LG.print("Game Over\nPressione R para reiniciar!",
        LG.getWidth() / 2 - 50,
        LG.getHeight() / 2 - 10
      )
  end
  -- Atualização dos disparos executados
  for i, proj in ipairs(disparos) do
    LG.draw(proj.img, proj.x, proj.y)
  end
  -- Atualizar os inimigos na tela
  for i, atual in ipairs(inimigos) do
    LG.draw(atual.img, atual.x, atual.y)
  end
end

-- Responsável pelas interações com o tempo
-- Animação, coleta de pressionar o teclado
function love.update(dt)
  -- Detecção de colisões
  for i, atual in ipairs(inimigos) do
    -- Inimigos com disparos
    for j, proj in ipairs(disparos) do
      if (verColisao(atual.x, atual.y, atual.img:getWidth(), 
          atual.img:getHeight(), proj.x, proj.y, 
          proj.img:getWidth(), proj.img:getHeight())) then
        -- Ocorreu colisao mata o inimigo
        table.remove(inimigos, i)
        table.remove(disparos, j)
        Pontos = Pontos + 10
      end
    end
    -- Verificar se o inimigo colidiu com o personagem
    if (verColisao(
        atual.x, atual.y, atual.img:getWidth(), 
          atual.img:getHeight(), jogador.posx, jogador.posy, 
          jogador.img:getWidth(), jogador.img:getHeight()
        )) then
      table.remove(inimigos, i)
      Vivo = false
    end
  end
  
  -- Controle da nave jogador
   if(LK.isDown('left','a'))then
    if(jogador.posx > 0) then
      jogador.posx = jogador.posx - (jogador.veloc * dt)
      end
    
  elseif(LK.isDown('right','d'))then
    if(jogador.posx < (LG.getWidth() - jogador.img:getWidth())) then
      jogador.posx = jogador.posx + (jogador.veloc * dt)
      end
  end
  
  if(LK.isDown('up','w'))then
    if(jogador.posy > 0) then
      jogador.posy = jogador.posy - (jogador.veloc * dt)
      end
  elseif(LK.isDown('down','s'))then
    if(jogador.posy < (LG.getHeight() - jogador.img:getHeight())) then
      jogador.posy = jogador.posy + (jogador.veloc * dt)
    end
  end
  
  -- Temporização de disparos
  tempoTiro = tempoTiro - (1 * dt)
  if (tempoTiro < 0) then
    podeTirar = true
  end
  -- Controle do disparos
  if (LK.isDown('space','rctrl','lctrl') and podeTirar) then
    -- Criar uma instância do projetil
    nvProj = {
        x = (jogador.posx + jogador.img:getWidth()/2),
        y = jogador.posy,
        img = imgProjetil
      }
    table.insert(disparos, nvProj)
    -- Colocar o efeito sonoro do disparo
    Tiro:play()
    podeTirar = false
    tempoTiro = atiraMax
  end
  -- Atualização da posição dos tiros
  for i, proj in ipairs(disparos) do
    proj.y = proj.y - (250 * dt)
    -- Se o disparo sair da tela, eliminar
    if (proj.y < 0) then
      table.remove(disparos, i)
    end
  end
  -- Temporização da instancia de inimigos
  dtAtualInimigo = dtAtualInimigo - (1 * dt)
  if (dtAtualInimigo < 0) then
    dtAtualInimigo = dtMaxCriaInimigo
    -- Criar uma instância do inimigo
    posDinamica = math.random(10 + margemInimigo, LG.getWidth() - (10 + margemInimigo))
    nvInimigo = {x = posDinamica, y = -10, img = imgInimigo}
    table.insert(inimigos, nvInimigo)
  end
  -- Movimentação dos inimigos
  for i, atual in ipairs(inimigos) do
    atual.y = atual.y + (200 * dt)
    -- Se ele sair abaixo da tela, remover da lista
    if (atual.y > LG.getHeight()) then
      table.remove(inimigos, i)
    end
  end
  -- Reiniciar o jogo
  if (not Vivo and LK.isDown('r')) then
    -- Limpar as tabelas
    inimigos = {}
    disparos = {}
    -- Reiniciar os temporizadores
    tempoTiro = atiraMax
    dtAtualInimigo = dtMaxCriaInimigo
    -- Posicionar a nave
    jogador.posx = meioh
    jogador.posy = meiov
    -- Reinicia o placar
    Vivo = true
    Pontos = 0
  end
end

-- Função personalizada para controle de colisão
-- Método da Bouding Box (Caixa Continente)
function verColisao(x1, y1, w1, h1, x2, y2, w2, h2)
  return (x2 + w2 >= x1 and x2 <= x1 + w1 
    and y2 + h2 >= y1 and y2 <= y1 + h1)
end