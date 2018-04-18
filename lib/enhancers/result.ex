defmodule ChessPlus.Result do
  alias LifeBloom.Bloom
  alias ChessPlus.Matrix

  @type result :: {:ok, term}
    | {:error, String.t}

  @spec retn(term) :: result
  def retn(value), do: {:ok, value}

  @spec map(result, fun) :: result
  def map({:ok, value}, handle) do
    {:ok, handle.(value)}
  end

  def map(err, _), do: err

  def result <|> handle, do: map(result, handle)

  @spec appl(result, result) :: result
  def appl({:ok, handle}, {:ok, value}) do
    Bloom.sow(handle)
    |> Bloom.nurish(value)
    |> (&{:ok, &1}).()
  end

  def appl({:ok, _}, err), do: err

  def appl(err, {:ok, _}), do: err

  def handle <~> result, do: appl(handle, result)

  @spec bind(result, fun) :: result
  def bind({:ok, value}, handle) do
    handle.(value)
  end

  def bind(err, _), do: err

  def result ~>> handle, do: bind(result, handle)

  @spec unwrap([result]) :: result
  def unwrap(results) when is_list(results) do
    Enum.reduce(results, {:ok, []}, fn
      {:ok, value}, {:ok, lst} -> {:ok, [value | lst]}
      _, {:error, _} = error -> error
      error, _ -> error
    end)
    |> (fn
      {:ok, lst} -> {:ok, Enum.reverse(lst)}
      error -> error
    end).()
  end

  @spec unwrap_matrix(Matrix.matrix) :: result
  def unwrap_matrix(matrix) do
    rows = Matrix.rows(matrix)
    |> unwrap()

    cols = Matrix.columns(matrix)
    |> Enum.map(&unwrap/1)
    |> unwrap()

    items = Matrix.items(matrix)
    |> Enum.map(&unwrap/1)
    |> unwrap()

    {:ok, &Matrix.zip/3}
    <~> rows
    <~> cols
    <~> items
  end

  @spec orElse(result, term) :: term
  def orElse({:error, _}, default), do: default
  def orElse({:ok, val}, _), do: val

  @spec orElseWith(result, fun) :: term
  def orElseWith({:error, err}, handle), do: handle.(err)
  def orElseWith({:ok, val}, _), do: val

  @spec into(result, Collectable.t) :: result
  def into(result, collectable) do
    result
    <|> fn mp -> Enum.into(mp, collectable) end
  end
end
