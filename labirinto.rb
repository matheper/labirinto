def novo_individuo(cromossomo = [])
  { :cromossomo => cromossomo }.tap do |individuo|
    BITS.times { individuo[:cromossomo] << rand(4) } if cromossomo.empty?
    individuo[:fitness] = fitness(individuo)
  end
end

def nova_populacao(tamanho)
  [].tap do |individuos|
    tamanho.times { individuos << novo_individuo }
  end
end

def fitness(individuo)
  posicao = ENTRADA
  saida = false

  fitness = individuo[:cromossomo].reduce(0) do |fitness, gene|
    if posicao[0] > 9 or posicao[0] < 0 or posicao[1] > 9 or posicao[1] < 0
      fitness += 50 unless saida
    else
      celula = LABIRINTO[posicao[0]][posicao[1]]
      shift = 1 << gene
      fitness += ((celula & shift) * 10) unless saida
    end

    direcao = DIRECOES[gene]
    posicao = [posicao[0] + direcao[0], posicao[1] + direcao[1]]

    fitness += 1 unless saida

    saida = true if posicao == SAIDA

    fitness
  end

  fitness += 50 unless saida

  fitness
end

def crossover(pais, cortes)
  cromossomo = []
  tamanho = (BITS / cortes.to_f).ceil
  n = pais.size

  cortes.times do |corte|
    comeco = tamanho * corte
    n.times do |i|
      cromossomo.concat(pais[rand(n)][:cromossomo].slice(comeco, tamanho))
    end
  end

  novo_individuo(cromossomo)
end

def selecao(individuos, populacao)
  individuos.sort { |a, b| a[:fitness] <=> b[:fitness] }[0...populacao]
end

def selecao_torneio(individuos)
  elite = []
  individuos.each_slice(2) do |s|
    if s.size > 1
      elite << (s[0][:fitness] < s[1][:fitness] ? s[0] : s[1])
    else
      elite << s[0]
    end
  end
  elite
end

def mutacao(individuo)
  cromossomo = individuo[:cromossomo].dup
  rand(BITS_MUTACAO).times do
    cromossomo[rand(55)] = rand(4)
  end
  novo_individuo(cromossomo)
end

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
POPULACAO_INICIAL = 80
BITS = 55
ENTRADA = [9, 0]
SAIDA = [0, 9]
CORTES = 11
PAIS = 3
FILHOS = 2
ITERACOES_MUTACAO = 10
BITS_MUTACAO = 5

individuos = nova_populacao(POPULACAO_INICIAL)

i = 1
while i = (i + 1 % ITERACOES_MUTACAO)
  novos_individuos = []
  individuos.each_slice(PAIS) do |slice|
    slice = slice.map { |x| i == 0 ? mutacao(x) : x }
    novos_individuos.concat slice
    FILHOS.times { novos_individuos << crossover(slice, CORTES) }
  end
  individuos = selecao(novos_individuos, POPULACAO_INICIAL)
  #individuos = selecao_torneio(novos_individuos)

  puts individuos.reduce(999999) { |menor, individuo|
    individuo[:fitness] < menor ? individuo[:fitness] : menor
  }
end
