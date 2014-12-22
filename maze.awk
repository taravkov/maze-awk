#! /usr/bin/awk -f

BEGIN {
    # Будем форматировать вывод вручную
    OFS = "";
    ORS = "";

    system("gcc -lcurses -o input input.c");
    system("tput civis");

    srand();
    main();
}

function main() {
    generateMaze();
    gameLoop();
}

function generateMaze() {
    sizeX = 8;
    sizeY = 8;
    visibleX = 8;
    visibleY = 4;
    size = sizeX * sizeY; # Размер лабиринта (количество ячеек)
    setUnique = 1; # Текущий номер уникального множества

    # Инициализируем переменные
    for(i = 0; i < size; i++) {
	set[i] = 0;
	rightBound[i] = 0;
	bottomBound[i] = 0;
    }

    # Цикл по строкам лабиринта
    for(i = 0; i < sizeY; i++) {
	offset = i * sizeX;
	# Цикл по столбцам лабиринта
	for(j = offset; j < offset + sizeX; j++) {
	    # Присвоим пустым ячейкам уникальное множество
	    if(!set[j]) {
		set[j] = setUnique++;
	    }
	}

	# Создадим границы справа
	for(j = offset; j < offset + (sizeX - 1); j++) {
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

	if(i != (sizeY - 1)) {
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
	else {
	    for(j = offset; j < offset + (sizeX - 1); j++) {
		# Добавим нижнюю границу к каждой ячейке
		bottomBound[j] = 1;

		# Удалим правую границу, если соседние
		# ячейки принадлежат разным множествам
		if(set[j] != set[j+1]) {
		    rightBound[j] = 0;
		    # И объеденим эти множества
		    union(set[j], set[j+1]);
		}
	    }
	    bottomBound[size-1] = 1;	
	}
    }
}

function drawMaze() {
    system("clear");

    # Печать верхней границы
    print " ";
    if(drawOriginY == 0) {
	for(i = 0; i < visibleX; i++) {
	    print "____ ";
	}
    }
    else {
	offset = (drawOriginY * sizeX) + drawOriginX - sizeX;
	for(i = offset; i < offset + visibleX; i++) {
	    if(bottomBound[i]) print "____ "
	    else print "     ";
	}
    }
    print "\n";

    for(i = drawOriginY; i < drawOriginY + visibleY; i++) {
	offset = (i * sizeX) + drawOriginX;
	for(k = 0; k < 2; k++) {
	    if(drawOriginX == 0) print "|";
	    else {
		if(rightBound[offset-1]) print "|";
		else print " ";
	    }
	    for(j = offset; j < offset + visibleX; j++) {
		if(k == 0) {
		    if(position == j) print "ಠ_ಠ ";
		    else print "    ";
		    if(rightBound[j]) print "|";
		    else print " ";
		}
		if(k == 1) {
		    if(bottomBound[j]) print "____";
		    else print "    ";
		    if(rightBound[j]) print "|";
		    else print " ";
		}
	    }
	    print "\n";
	}
    }

    print "Steps: " steps "\n";
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

function gameLoop() {
    # Позиция игрока
    position = 0;
    # Выход
    winPosition = size;
    rightBound[size-1] = 0;
    drawOriginX = 0;
    drawOriginY = 0;
    steps = 0;

    while(1) {
	if(position == winPosition) break;

	drawMaze();

	"./input" | getline input
	close("./input");

	if(input == "LEFT") goLeft();
	if(input == "DOWN") goDown();
	if(input == "UP") goUp();
	if(input == "RIGHT") goRight();
	if(input == "QUIT") quit();

	steps++;
    }

    youWin();
}

function goLeft() {
    if((position % sizeX != 0) && !rightBound[position-1]) {
	position -= 1;
	if((position % sizeX) < drawOriginX) {
	    drawOriginX -= visibleX;
	}
    }
    else print "\a";
}

function goDown() {
    if(!bottomBound[position]) {
	position += sizeX;
	if((position / sizeX) >= (drawOriginY + visibleY)) {
	    drawOriginY += visibleY;
	}
    }
    else print "\a";
}

function goUp() {
    above = position - sizeX;
    if((above >= 0) && !bottomBound[above]) {
	position -= sizeX;
	if((position / sizeX) < drawOriginY) {
	    drawOriginY -= visibleY;
	}
    }
    else print "\a";
}

function goRight() {
    if(!rightBound[position]) {
	position += 1;
	if((position % sizeX) >= (drawOriginX + visibleX)) {
	    drawOriginX += visibleX;
	}
    }
    else print "\a";
}

function youWin() {
    system("clear");
    system("cat ./win.txt");

    while(1) {
	"./input" | getline input
	close("./input");

	if(input == "QUIT") quit();
    }
}

function quit() {
    system("tput cnorm");
    exit;
}