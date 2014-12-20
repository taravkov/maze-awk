#! /usr/bin/awk -f

BEGIN {
    # Будем форматировать вывод вручную
    OFS = "";
    ORS = "";

    main();
}

function main() {
    sizeX = 8;
    sizeY = 8;
    size = sizeX * sizeY; # Размер лабиринта (количество ячеек)

    set[size]; # Множество, содержащее ячейку
    rightBound[size]; # Правые границы ячеек
    bottomBound[size]; # Нижние границы ячеек

    generateMaze(sizeX, sizeY, set, rightBound, bottomBound);
}

function generateMaze(sizeX, sizeY, set, rightBound, bottomBound) {
    setUnique = 1; # Текущий номер уникального множества

    # Инициализируем переменные
    for(i = 0; i < size; i++) {
	set[i] = 0;
	rightBound[i] = 0;
	bottomBound[i] = 0;
    }

    # Цикл по строкам лабиринта
    for(i = 0; i < sizeY - 1; i++) {
	offset = i * sizeX;
	# Цикл по столбцам лабиринта
	for(j = 0; j < sizeX; j++) {
	    # Удалим все правые границы 
	    rightBorder[offset+j] = 0;
	    # Удалим ячейки с нижней границей из их множества
	    if(bottomBorder[offset+j] == 1) {
		set[offset+j] = 0;
	    }
	    # Удалим все нижние границы
	    bottomBorder[offset+j] = 0;
	    # Присвоим пустым ячейкам уникальное множество
	    if(set[offset+j] == 0) {
		set[offset+j] = setUnique;
		setUnique++;
	    }
	}

	# Создадим границы справа
	for(j = 0; j < sizeX - 1; j++) {
	    # Решим, добавлять ли границу справа
	    bound = rand();
	    if(bound > 0.5) bound = 1;
	    else bound = 0;
	
	    # Создадим границу, если текущая
	    # ячейка и ячейка справа
	    # принадлежат одному множеству
	    if(set[offset+j] == set[offset+j+1]) {
		rightBound[offset+j] = 1;
		continue;
	    }

	    if(bound) rightBound[offset+j] = 1;
	    else set[offset+j+1] = set[offset+j];
	}

	# Создадим границы снизу
	for(j = 0; j < sizeX; j++) {
	    # Решим, добавлять ли границу снизу
	    bound = rand();
	    if(bound > 0.5) bound = 1;
	    else bound = 0;

	    # Если ячейка одна в своем множестве,
	    # то нижняя граница не добавляется
	    alone = 1;
	    for(k = 0; k < sizeX; k++) {
		if(j == k) continue;
		if(set[offset+j] == set[offset+k]) {
			alone = 0;
			break;
		}
	    }
	    if(alone) bound = 0;
	    else {
		# Если ячейка одна в своем множестве без
		# нижней границы, то нижняя граница не
		# создается
		alone = 1;
		for(k = 0; k < sizeX; k++) {
		    if(j == k) continue;
		    if(set[offset+j] == set[offset+k]) {
			if(bottomBound[offset+k] == 1) {
			    alone = 0;
			    break;
			}
		    }
		}
		if(alone) bound = 0;
	    }

	    if(bound) bottomBound[offset+j] = 1;
	}

	# Скопируем строку в следующую
	for(j = 0; j < sizeX; j++) {
	    set[offset+sizeX+j] = set[offset+j];
	    rightBound[offset+sizeX+j] = rightBorder[offset+j];
	    bottomBound[offset+sizeX+j] = bottomBorder[offset+j];
	}
    }

    # Последняя строка
    for(i = 0; i < sizeX - 1; i++) {
	offset = sizeX * (sizeY - 1);
	# Добавим нижнюю границу к каждой ячейке
	bottomBound[offset+i] = 1;
	# Удалим правую границу, если соседние
	# ячейки принадлежат разным множествам
	if(set[offset+j] != set[offset+j+1]) {
	    rightBound[offset+j] = 0;
	    # И объеденим эти множества
	    set[offset+j+1] = set[offset+j];
	}
    }
}