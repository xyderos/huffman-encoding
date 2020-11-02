defmodule Huffman do

  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end

  def text() do
    'this is something that we should encode'
  end

  def tree(sample) do
    freq = freq(sample)
    huffman(freq)
  end

  def freq(msg), do: Enum.sort(freq(msg, []), fn ({_, f1}, {_, f2}) -> f1 <= f2 end)

  def freq(sample), do: freq(sample,[])

  def freq([], freq), do: freq

  def freq([char | rest], freq), do: freq(rest, enqueue(freq, char))

  def enqueue([], char), do: [{char, 1}]

  def enqueue([{char, f} | rest], char), do: [{char, f+1} | rest]

  def enqueue([tuple | rest], char), do: [tuple | enqueue(rest, char)]

  def huffman([{tree, _}]), do: tree

  def huffman([{c1, f1}, {c2, f2} | rest]), do: huffman(insert({{c1, c2}, f1 + f2}, rest))

  def insert({c, f}, []), do: [{c, f}]

  def insert({c, f}, [{ch, fh} | t]) when f <= fh , do: [{c, f}, {ch, fh} | t]

  def insert({c, f}, [h | t]), do: [h | insert({c, f}, t)]

  def encode_table(tree), do: tree_to_table(tree, [], [])

  def tree_to_table({}, _, acc), do: acc

  def tree_to_table({left, right}, path, acc), do: tree_to_table(left, path ++ [0], acc) ++ tree_to_table(right, path ++ [1], acc) ++ acc

  def tree_to_table(char, path, _), do: [{char, path}]

  def encode([], _), do: []

  def encode([char | rest], table), do: encode_char(char, table) ++ encode(rest, table)

  def encode_char(char, [{char, path} | _]), do: path

  def encode_char(char, [{_, _} | rest]), do: encode_char(char, rest)

  def decode([], _), do: []

  def decode(seq, table) do
    {char, rest} = decode_char(seq, 1, table)
    [char | decode(rest, table)]
  end

  def decode_char(seq, n, table) do
    {code, rest} = Enum.split(seq, n)
    case List.keyfind(table, code, 1) do
      {char,_} -> {char, rest}
      nil ->
        decode_char(seq, n + 1, table)
    end
  end

  def read(file, n) do
    {:ok, file} = File.open(file, [:read])
    binary = IO.read(file, n)
    File.close(file)
    case :unicode.characters_to_list(binary, :utf8) do
      {:incomplete, list, _} -> list;
      list -> list
    end
  end
end
