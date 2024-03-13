# Модуль dynamic_array.pyx

from libc.stdlib cimport malloc, free
from libc.string cimport memcpy

cdef class Array:
    cdef void * data  # Указатель на данные в массиве
    cdef int item_size  # Размер элемента массива в байтах (int или double)
    cdef int length  # Текущая длина массива
    cdef int capacity  # Емкость массива

    def __cinit__(self, str data_type, data=None):
        """
        Конструктор класса Array.

        Args:
            data_type (str): Тип данных массива. Используйте 'i' для int или 'd' для double.
            data (list[int] or list[float], optional): Исходные данные для инициализации массива.

        Raises:
            ValueError: Если передан недопустимый тип данных.

        Создает новый экземпляр класса Array с указанным типом данных и,
         при наличии исходных данных, их инициализацией.
        """
        if data_type not in {'i', 'd'}:
            raise ValueError("Недопустимый тип данных. "
                             "Используйте 'i' для int или 'd' для double.")

        self.item_size = sizeof(int) if data_type == 'i' else sizeof(double)
        self.length = 0
        self.capacity = 1
        self.data = malloc(self.capacity * self.item_size)
        if data is not None:
            self.extend(data)

    def __dealloc__(self):
        """
        Деструктор класса Array.

        Освобождает выделенную память при уничтожении объекта.
        """
        free(self.data)

    cdef void _resize(self, int new_capacity):
        """
        Изменяет размер массива.

        Args:
            new_capacity (int): Новая емкость массива.

        Увеличивает емкость массива до новой заданной величины и копирует данные в новую память,
         при необходимости.
        """
        new_data = malloc(new_capacity * self.item_size)
        memcpy(new_data, self.data, self.length * self.item_size)
        free(self.data)
        self.data = new_data
        self.capacity = new_capacity

    def append(self, item):
        """
        Добавляет элемент в конец массива.

        Args:
            item (int or float): Элемент для добавления.

        Raises:
            TypeError: Если тип элемента не соответствует типу массива.

        Добавляет элемент в конец массива. При необходимости увеличивает емкость массива.
        """
        if self.item_size == sizeof(int) and not isinstance(item, int):
            raise TypeError("Невозможно добавить нецелое значение в массив целых чисел")

        if self.length == self.capacity:
            self._resize(self.capacity * 2)

        if self.item_size == sizeof(int):
            (<int *> self.data)[self.length] = item
        else:
            (<double *> self.data)[self.length] = item

        self.length += 1

    def extend(self, items):
        """
        Добавляет несколько элементов в конец массива.

        Args:
            items (list[int] or list[float]): Список элементов для добавления.

        Добавляет все элементы из списка items в конец массива.
        """
        for item in items:
            self.append(item)

    def insert(self, index, item):
        """
        Вставляет элемент по указанному индексу.

        Args:
            index (int): Индекс, по которому нужно вставить элемент.
            item (int or float): Элемент для вставки.

        Raises:
            IndexError: Если индекс вне диапазона.

        Вставляет элемент по указанному индексу.
        При необходимости увеличивает емкость массива.
        """
        if type(index) != int:
            raise IndexError("Индекс вне диапазона")

        if index < 0:
            index = self.length + index

        if self.length == self.capacity:
            self._resize(self.capacity * 2)

        if index > self.length:
            self.append(item)
        else:
            if index < 0:
                index = 0
            for i in range(self.length, index, -1):
                if self.item_size == sizeof(int):
                    (<int *> self.data)[i] = (<int *> self.data)[i - 1]
                else:
                    (<double *> self.data)[i] = (<double *> self.data)[i - 1]

            if self.item_size == sizeof(int):
                (<int *> self.data)[index] = item
            else:
                (<double *> self.data)[index] = item

            self.length += 1

    def remove(self, item):
        """
        Удаляет первое вхождение элемента из массива.

        Args:
            item (int or float): Элемент для удаления.

        Raises:
            ValueError: Если элемент не найден.

        Удаляет первое вхождение элемента из массива, если он присутствует.
        """
        for i in range(self.length):
            if (self.item_size == sizeof(int) and (<int *> self.data)[i] == item) or (
                    self.item_size == sizeof(double) and (<double *> self.data)[i] == item):
                self.pop(i)
                return

        raise ValueError("Элемент не найден")

    def pop(self, int index=-1):
        """
        Извлекает и удаляет элемент по индексу.

        Args:
            index (int, optional): Индекс элемента для извлечения.
            По умолчанию извлекается последний элемент.

        Raises:
            IndexError: Если индекс вне диапазона.

        Returns:
            int or float: Извлеченный элемент.

        Извлекает и удаляет элемент по индексу. При необходимости уменьшает емкость массива.
        """
        if self.length == 0:
            raise IndexError("Попытка извлечь элемент из пустого массива")

        if index >= self.length or index < -self.length or type(index) != int:
            raise IndexError("Индекс вне диапазона")

        if index < 0:
            index = self.length + index

        if self.item_size == sizeof(int):
            item = (<int *> self.data)[index]
        else:
            item = (<double *> self.data)[index]

        for i in range(index, self.length - 1):
            if self.item_size == sizeof(int):
                (<int *> self.data)[i] = (<int *> self.data)[i + 1]
            else:
                (<double *> self.data)[i] = (<double *> self.data)[i + 1]

        self.length -= 1

        if self.capacity > 1 and self.length <= self.capacity // 4:
            self._resize(self.capacity // 2)

        return item

    def __len__(self):
        """
        Возвращает текущую длину массива.

        Returns:
            int: Длина массива.
        """
        return self.length

    def __sizeof__(self):
        """
        Возвращает размер массива в байтах.

        Returns:
            int: Размер массива в байтах.
        """
        return self.capacity * self.item_size

    def __getitem__(self, int index):
        """
        Возвращает элемент по индексу.

        Args:
            index (int): Индекс элемента.

        Returns:
            int or float: Элемент массива.

        Raises:
            IndexError: Если индекс вне диапазона.
        """
        if index >= self.length or index < -self.length or type(index) != int:
            raise IndexError("Индекс вне диапазона")

        if index < 0:
            index = self.length + index

        if self.item_size == sizeof(int):
            return (<int *> self.data)[index]
        else:
            return (<double *> self.data)[index]

    def __setitem__(self, int index, value):
        """
        Устанавливает элемент по индексу.

        Args:
            index (int): Индекс элемента.
            value (int or float): Значение для установки.

        Raises:
            IndexError: Если индекс вне диапазона.
        """
        if index >= self.length or index < -self.length or type(index) != int:
            raise IndexError("Индекс вне диапазона")

        if index < 0:
            index = self.length + index

        if self.item_size == sizeof(int):
            (<int *> self.data)[index] = value
        else:
            (<double *> self.data)[index] = value

    def __reversed__(self):
        """
        Возвращает обратный итератор.

        Returns:
            reversed: Обратный итератор.
        """
        for i in range(self.length - 1, -1, -1):
            yield self[i]

    def __str__(self):
        return "[" + ", ".join(map(str, self)) + "]"

    def __eq__(self, other):
        """
        Сравнивает массив с другим массивом.

        Args:
            other (Array): Другой массив для сравнения.

        Returns:
            bool: True, если массивы равны, и False в противном случае.
        """
        if hasattr(other, "__iter__") and self.length == len(other):
            for i in range(self.length):
                if self[i] != other[i]:
                    break
            else: 
                return True
        return False

    def __iter__(self):
        """
        Итератор для массива.

        Returns:
            iter: Итератор для массива.
        """
        for i in range(self.length):
            yield self[i]
