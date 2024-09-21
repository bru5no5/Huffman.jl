# Definição da estrutura Node
struct Node
  char::Union{Char, Nothing}
  freq::Int
  esquerda::Union{Node, Nothing}
  direita::Union{Node, Nothing}
end

# Quicksort
# Função para particionar o array de nós
function particao(nodes, menor, maior)
  pivo = nodes[maior].freq
  i = menor - 1
  for j in menor:maior-1
    if nodes[j].freq <= pivo
      i += 1
      nodes[i], nodes[j] = nodes[j], nodes[i]
    end
  end
  nodes[i+1], nodes[maior] = nodes[maior], nodes[i+1]
  return i+1
end
# Função recursiva do quicksort
function quick(nodes, menor, maior)
  if menor < maior
    p_ivo = particao(nodes, menor, maior)
    quick(nodes, menor, p_ivo-1)
    quick(nodes, p_ivo+1, maior)
  end
end
# Função para chamar o quicksort
function quicksort(nodes)
  quick(nodes, 1, length(nodes))
  return nodes
end

# Ler o arquivo de texto e contar a frequência de cada caractere
function le_e_conta(arquivo)
  # Ler o conteúdo do arquivo especificado como String
  texto = read(arquivo, String)
  # Criar um dicionário para armazenar a frequência de caracteres
  freqs = Dict{Char, Int}()
  # Para cada caractere, verificar se é letra ou número e atualizar o dicionário com a contagem
  for char in texto
    if isletter(char) || isdigit(char)
      freqs[char] = get(freqs, char, 0) + 1
    end
  end
  # Retornar o dicionário de frequências
  return freqs
end

# Construir a árvore de Huffman com base na frequência dos caracteres
function constroi_arvore_huffman(freqs)
  # Criar uma lista de nós, onde cada nó contém um caractere e sua frequência
  nodes = [Node(char, freq, nothing, nothing) for (char, freq) in freqs]
  # Enquanto houver mais do que 1 nó na lista:
  while length(nodes) > 1
    # Ordenar a lista de nós com base na frequência
    quicksort(nodes)
    # Remover nós de menor frequência
    esquerda = popfirst!(nodes)
    direita = popfirst!(nodes)
    # Criar um novo nó combinando as duas frequências
    novo_node = Node(nothing, esquerda.freq + direita.freq, esquerda, direita)
    # Inserir o novo nó de volta na lista de nós
    push!(nodes, novo_node)
  end
  # Retornar o último nó como raiz da árvore de Huffman
  return nodes[1]
end

# Gerar os códigos binários de Huffman a partir da árvore de Huffman, percorrendo recursivamente a árvore
function gerar_codigos_huffman(node, prefixo = "", codigos = Dict{Char, String}())
  # Se o nó for folha, ou seja, tem caractere, adicionar o código binário ao dicionário de códigos
  if node.char != nothing
    codigos[node.char] = prefixo
  # Se não for folha, utiliza "0" para o ramo esquerdo e "1" para o ramo direito, e vai construindo o código binário do caractere
  else
    gerar_codigos_huffman(node.esquerda, prefixo * "0", codigos)
    gerar_codigos_huffman(node.direita, prefixo * "1", codigos)
  end
  # Retornar o dicionário de códigos de Huffman para cada caractere
  return codigos
end

# Codificar o texto original usando os códigos de Huffman
function codifica_texto(texto, codigos)
  texto_codificado = ""
  # Para cada caractere no texto, substituir pelo seu código correspondente, adicionar na string codificada
  for char in texto
    if haskey(codigos, char)
      texto_codificado *= codigos[char]
    end
  end
  # Retornar a string codificada
  return texto_codificado
end

# Função main
function main()
  # Imprimir os créditos de escrita desse código na tela
  println("""
    Créditos do algoritmo:
    Bruno Gustavo Rocha
  """)
  # Ler o arquivo de texto e contar a frequência de cada caractere
  freqs = le_e_conta("in.txt")
  # Escrever a tabela de frequências em um arquivo de texto
  open("freq.txt", "w") do file
    for (char, freq) in freqs
      write(file, "$char $freq\n")
    end
  end
  # Construir a árvore de Huffman com base na frequência dos caracteres
  huffman_arvore = constroi_arvore_huffman(freqs)
  # Gerar os códigos de Huffman para os caracteres
  huffman_codigos = gerar_codigos_huffman(huffman_arvore)
  # Escrever a tabela de códigos de Huffman em um arquivo de texto
  open("huffman.txt", "w") do file
    for (char, code) in huffman_codigos
      write(file, "$char $code\n")
    end
  end
  # Codificar o texto original usando os códigos de Huffman
  texto = read("in.txt", String)
  texto_codificado = codifica_texto(texto, huffman_codigos)
  # Escrever o texto codificado no arquivo de texto de saída
  open("out.txt", "w") do file
    write(file, texto_codificado)
  end
  # Imprimir a confirmação da conclução do processamento
  println("Processamento concluído com sucesso!")
end

# Chamada da função main
main()
