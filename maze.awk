#! /usr/bin/awk -f

BEGIN {
    # Будем форматировать вывод вручную
    OFS = "";
    ORS = "";

    srand();
    main();
}

function main() {
    generateMaze();
    drawMaze();
}

function generateMaze() {
    sizeX = 16;
    sizeY = 16;
    size = sizeX * sizeY; # Размер лабиринта (количество ячеек)

    set[size]; # Множество, содержащее ячейку
    rightBound[size]; # Правые границы ячеек
    bottomBound[size]; # Нижние границы ячеек

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
	for(j = offset; j < offset + sizeX; j++) {
	    # Присвоим пустым ячейкам уникальное множество
	    if(!set[j]) {
		set[j] = setUnique++;
	    }
	}

	# Создадим границы справа
	for(j = offset; j < offset + sizeX - 1; j++) {
	    # Решим, добавлять ли границу справа
	    bound = rand();
	    if(bound > 0.5) bound = 1;
	    else bound = 0;
	
	    # Создадим границу, если текущая
	    # ячейка и ячейка справа
	    # принадлежат одному множеству
	    if(set[j] == set[j+1]) {
		bound = 1;
	    }

	    if(bound) rightBound[j] = 1;
	    else union(set[j], set[j+1]);
	}
	rightBound[offset+sizeX-1] = 1;

	# Создадим границы снизу
	for(j = offset; j < offset + sizeX; j++) {
	    # Решим, добавлять ли границу снизу
	    bound = rand();
	    if(bound > 0.5) bound = 1;
	    else bound = 0;

	    # Если ячейка одна в своем множестве,
	    # то нижняя граница не добавляется
	    alone = 1;
	    for(k = offset; k < offset + sizeX; k++) {
		if((set[j] == set[k]) && (j != k)) {
			alone = 0;
			break;
		}
	    }
	    if(alone) bound = 0;
	    
	    # Если ячейка одна в своем множестве без
	    # нижней границы, то нижняя граница не
	    # создается
	    alone = 1;
	    for(k = offset; k < offset + sizeX; k++) {
		if((set[j] == set[k]) && (j != k)) {
		    if(!bottomBound[k]) {
			alone = 0;
			break;
		    }
		}
	    }
	    if(alone) bound = 0;

	    if(bound) bottomBound[j] = 1;
	}

	# Скопируем строку в следующую
	for(j = offset; j < offset + sizeX; j++) {
	    set[sizeX+j] = set[j];
	    bottomBound[sizeX+j] = bottomBound[j];

	    # Удалим ячейки с нижней границей из их множества
	    if(bottomBound[sizeX+j]) {
		set[sizeX+j] = 0;
	    }
	    # Удалим все нижние границы
	    bottomBound[sizeX+j] = 0;
	}	
    }

    # Скопируем предпоследнюю строку
    for(i = size - sizeX; i < size; i++) {
	set[i] = set[i-sizeX];
	rightBound[i] = rightBound[i-sizeX];
	bottomBound[i] = bottomBound[i-sizeX];
    }

    # Последняя строка
    for(i = size - sizeX; i < size - 1; i++) {
	# Добавим нижнюю границу к каждой ячейке
	bottomBound[i] = 1;

	# Удалим правую границу, если соседние
	# ячейки принадлежат разным множествам
	if(set[i] != set[i+1]) {
	    rightBound[i] = 0;
	    # И объеденим эти множества
	    union(set[i], set[i+1]);
	}
    }
    bottomBound[size-1] = 1;
}

function drawMaze() {
    # Печать верхней границы
    print " ";
    for(i = 0; i < sizeX; i++) {
	print "_ ";
    }
    print "\n";

    # Печать строк
    for(i = 0; i < sizeY; i++) {
	offset = i * sizeX;

	print "|";
	for(j = offset; j < offset + sizeX; j++) {
	    # Печать нижней границы
	    if(bottomBound[j]) {
		print "_";
	    }
	    else print " ";

	    # Печать правой границы
	    if(rightBound[j]) {
		print "|";
	    }
	    else print " ";
	}
	print"\n";
    }
}

function debug(row) {
    offset = row * sizeX;

    print"|";
    for(d = offset; d < offset + sizeX; d++) {
	if(bottomBound[d]) print "_";
	else print " ";
	print set[d];
	if(bottomBound[d]) print "_";
	else print " ";
	if(rightBound[d]) print "|";
	else print " ";
    }
    print"|\n";
}

function union(set1, set2) {
    # Объединение множеств
    for(s = 0; s < size; s++) {
	if(set[s] == set2) {
	    set[s] = set1;
	}
    }
}