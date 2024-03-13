# Модуль binary_search.py
def search(arr: list[int], item: int) -> int | None:
    """
    Выполняет бинарный поиск элемента в отсортированном списке arr.

    Args:
        arr (list[int]): Отсортированный список целых чисел, в котором будет выполняться поиск.
        item (int): Элемент, который необходимо найти в списке.

    Returns:
        int | None: Индекс элемента item в списке arr, если он найден, или None,
         если элемент не найден.

    Реализует бинарный поиск элемента item в отсортированном списке arr.
    Если элемент найден, функция возвращает его индекс в списке,
     в противном случае возвращает None.

    Пример использования:
    
    >>> arr = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    >>> search(arr, 5)
    4
    >>> search(arr, 10)
    None
    >>> search(arr, 0)
    None
    """
    if not arr:
        return None
    left_side = -1
    right_side = len(arr)
    while right_side > left_side + 1:
        middle = (left_side + right_side) // 2
        if arr[middle] >= item:
            right_side = middle
        else:
            left_side = middle
    if item > arr[-1] or item < arr[0]:
        return None
    return right_side if arr[right_side] == item else None
