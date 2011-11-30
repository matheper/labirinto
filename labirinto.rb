LABIRINTO = [
  [ 8, 10, 10, 10,  3,  6, 10, 10,  3,  6],
  [ 5, 14, 10, 10,  9,  5,  6,  3, 12,  9],
  [ 4, 10, 10, 10, 10,  1, 13,  4, 10,  3],
  [12, 10, 10,  3, 14,  8, 10,  9,  7,  5],
  [ 6, 11,  6,  1,  6, 10, 10, 10,  9, 12],
  [12, 10,  1,  4,  8, 10, 10, 10, 10,  3],
  [ 6, 10,  9,  5, 14,  2,  3,  6, 10,  9],
  [ 4,  2, 10,  8,  2,  1,  5, 12, 10,  3],
  [ 5,  5, 14, 11,  5,  5, 12, 10, 10,  1],
  [ 9, 12, 10, 10,  9, 12, 10, 10, 10,  9]]

DIRECOES = [[0, 1], [-1, 0], [0, -1], [1, 0]]
POPULACAO_INICIAL = 100

individuos = []

POPULACAO_INICIAL.times do |i|
  individuo = { :cromossomo => [] }
  55.times do |i|
    individuo[:cromossomo] << rand(4)
  end
  individuos << individuo
end

def fitness(individuo)
  individuo[:fitness] = 0
  posicao = [9, 0]
  saida = false

  individuo[:cromossomo].each do |gene|
    if posicao[0] > 9 or posicao[0] < 0 or posicao[1] > 9 or posicao[1] < 0
      individuo[:fitness] += 50 unless saida
    else
      celula = LABIRINTO[posicao[0]][posicao[1]]
      shift = 1 << gene
      individuo[:fitness] += ((celula & shift) * 10) unless saida
    end
    direcao = DIRECOES[gene]
    posicao = [posicao[0] + direcao[0], posicao[1] + direcao[1]]

    individuo[:fitness] += 1 unless saida
    
    saida = true if posicao == [0, 9]
  end

  individuo[:fitness] += 50 unless saida

  individuo[:fitness]
end

def crossover(pai, mae)
  filho = { :cromossomo => [] }
  filha = { :cromossomo => [] }

  cortes = 2.0
  tamanho = (pai.size / cortes).ceil
  pais = [pai, mae]

  cortes.to_i.times do |x|
    comeco = tamanho * x
    range = [comeco..(comeco+tamanho)]
    filho[:cromossomo].concat(pais[0][:cromossomo].slice(range))
    filha[:cromossomo].concat(pais[1][:cromossomo].slice(range))
    pais.reverse!
  end

  fitness(filho)
  fitness(filha)

  [filho, filha]
end

def selecao(individuos)
  elite = individuos.size / 2
  individuos.sort { |a, b| a[:fitness] <=> b[:fitness] }[0...elite]
end

individuos.each do |individuo|
  fitness(individuo)
end

while true
  novos_individuos = []
  selecao(individuos).each_slice(2) do |slice|
    novos_individuos.concat slice
    novos_individuos.concat crossover(*slice)
  end
  puts novos_individuos.reduce(9999) { |menor, individuo|
    if individuo[:fitness] < menor
      individuo[:fitness]
    else
      menor
    end
  }
  individuos = novos_individuos
end
