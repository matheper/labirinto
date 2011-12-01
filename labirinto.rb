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
      fitness += 1000 unless saida
    else
      celula = LABIRINTO[posicao[0]][posicao[1]]
      fitness += ((celula & 1 << gene) > 0 ? 10 : 0) unless saida
    end

    direcao = DIRECOES[gene]
    posicao = [posicao[0] + direcao[0], posicao[1] + direcao[1]]

    fitness += 1 unless saida

    saida = true if posicao == SAIDA

    fitness
  end

  fitness += 1000 unless saida

  fitness
end

def crossover(pais)
  if rand < 0.6
    corte = rand(BITS)
    filhos = [] << novo_individuo(pais[0][:cromossomo].slice(0, corte).concat(pais[1][:cromossomo].slice(corte, BITS)))
    filhos << novo_individuo(pais[1][:cromossomo].slice(0, corte).concat(pais[0][:cromossomo].slice(corte, BITS)))
  else
    pais.map { |p| mutacao(p) }
  end
end

def selecao(individuos, populacao)
  individuos.sort { |a, b| a[:fitness] <=> b[:fitness] }[0...populacao]
end

def mutacao(individuo)
  cromossomo = individuo[:cromossomo].dup.map do |gene|
    if rand <= 0.01
      rand(4)
    else
      gene
    end
  end
  novo_individuo(cromossomo)
end

LABIRINTO = [
  [ 6, 10, 10, 10,  3,  6, 10, 10,  3,  6],
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
POPULACAO_INICIAL = 500
BITS = 55
ENTRADA = [9, 0]
SAIDA = [0, 9]
individuos = nova_populacao(POPULACAO_INICIAL)
iteracoes = 0

begin
  while iteracoes += 1
    novos_individuos = selecao(individuos, 10)
    individuos.each_slice(2) do |slice|
      novos_individuos.concat crossover(slice)
    end
    individuos = selecao(novos_individuos, POPULACAO_INICIAL).shuffle

    puts individuos.reduce(999999) { |menor, individuo|
      individuo[:fitness] < menor ? individuo[:fitness] : menor
    }
  end
rescue Interrupt
  puts selecao(individuos, 1).reverse, iteracoes
end
