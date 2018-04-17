defmodule ChessPlus.Matrix do
  import ChessPlus.Result, only: [<|>: 2]

  @type row :: term
  @type column :: term
  @type item :: term
  @type matrix :: %{
    optional(row) => %{
      optional(column) => item
    }
  }
  @type result :: ChessPlus.Result.result

  @spec empty() :: matrix
  def empty() do
    %{}
  end

  @spec retn(item, row, column) :: matrix
  def retn(item, row, column) do
    %{row => %{column => item}}
  end

  @spec add(matrix, row, column, item) :: matrix
  def add(matrix, row, column, item) do
    matrix
    |> Map.update(row, %{column => item}, &Map.put(&1, column, item))
  end

  @spec map(matrix, fun) :: matrix
  def map(matrix, handle) do
    {_, arity} = :erlang.fun_info(handle, :arity)
    case arity do
      1 -> map_item(matrix, handle)
      3 -> map_r_c_item(matrix, handle)
      _ -> matrix # TODO error handling
    end
  end

  defp map_r_c_item(matrix, handle) do
    matrix
    |> Enum.map(fn {row, column} ->
      {
        row,
        Enum.map(column, fn {col, item} -> {col, handle.(row, col, item)} end)
        |> Enum.into(%{})
      }
    end)
    |> Enum.into(%{})
  end

  defp map_item(matrix, handle) do
    map_r_c_item(matrix, fn _, _, item -> handle.(item) end)
  end

  @spec reduce(matrix, term, (row, column, item, term -> term)) :: term
  def reduce(matrix, state, reducer) do
    matrix
    |> Enum.reduce(state, fn {row, column}, state ->
      Enum.reduce(column, state, fn {col, item}, state -> reducer.(row, col, item, state) end)
    end)
  end

  @spec initialize([row], [column], item) :: matrix
  def initialize(rows, columns, item) do
    items = 1..length(columns)
    |> Enum.map(fn _ -> item end)

    row_content = Enum.zip(columns, items)
    |> Enum.into(%{})

    row_contents = 1..length(rows)
    |> Enum.map(fn _ -> row_content end)

    Enum.zip(rows, row_contents)
    |> Enum.into(%{})
  end

  @spec fetch(matrix, row, column) :: result
  def fetch(matrix, row, column) do
    case Map.fetch(matrix, row) do
      :error -> {:error, "Row not found on matrix"}
      ok -> ok
    end
    <|> fn col ->
      case Map.fetch(col, column) do
        :error -> {:error, "Column not found on matrix"}
        ok -> ok
      end
    end
  end

  @spec filter(matrix, (item -> boolean)) :: matrix
  def filter(matrix, predicate) do
    reduce(matrix, empty(), fn row, column, item, state ->
      case predicate.(item) do
        true -> add(state, row, column, item)
        false -> state
      end
    end)
  end

  @spec update(matrix, row, column, (item -> item)) :: matrix
  def update(matrix, row, column, updater) do
    matrix
    |> Map.update!(row, &Map.update!(&1, column, updater))
  end

  @spec update(matrix, row, column, item, (item -> item)) :: matrix
  def update(matrix, row, column, initial, updater) do
    matrix
    |> Map.update(row, %{column => initial}, &Map.update(&1, column, initial, updater))
  end

  @spec update_where(matrix, (item -> boolean), (item -> item)) :: matrix
  def update_where(matrix, predicate, updater) do
    matrix
    |> map(fn item ->
      case predicate.(item) do
        true -> updater.(item)
        false -> item
      end
    end)
  end
end
