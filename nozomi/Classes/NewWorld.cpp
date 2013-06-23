#include "NewWorld.h"
#include <float.h>
#include <math.h>

//#define zend_isinf(a)   ((_fpclass(a) == _FPCLASS_PINF) || (_fpclass(a) == _FPCLASS_NINF))
//#define zend_isnan(x)   _isnan(x)

#ifndef max
#define max(a, b) ((a) > (b)) ? (a) : (b)
#define min(a, b) ((a) < (b)) ? (a) : (b)
#endif
double my_round(double val) {
    double t;
    //double f = pow(10.0, (double) places);
    double f = 1;
    double x = val * f;
  
    /*
    if (zend_isinf(x) || zend_isnan(x)) {
        return val;
    }
    */

    if (x >= 0.0) {
        t = ceil(x);
        if ((t - x) > 0.50000000001) {
            t -= 1.0;
        }
    } else {
        t = ceil(-x);
        if ((t + x) > 0.50000000001) {
            t -= 1.0;
        }
        t = -t; 
    }
    x = t / f;
    return x;
    //return !zend_isnan(x) ? x : t;
}
/*
BuildingInfo *intSearch(hashtab_t *h, int k) {
    return (BuildingInfo *)ht_search(h, &k, sizeof(k));
}
void *intInsert(hashtab_t *h, int k, BuildingInfo *b) {
    return ht_insert(h, &k, sizeof(k), b, sizeof(*b));
}
void intRemove(hashtab_t *h, int k) {
    return ht_remove(h, &k, sizeof(k));
}
*/
CCPoint cartesianToNormal(int x, int y) {
    return ccp(my_round(x/23), my_round(y/17.25));
}
CCPoint normalToAffine(int x, int y) {
    return ccp(my_round((x+y)/2), my_round((y-x)/2));
}
CCPoint cartesianToNormalFloat(float x, float y) {
    return ccp(x/23, y/17.25);
}
CCPoint normalToAffineFloat(float x, float y) {
    return ccp((x+y)/2, (y-x)/2);
}
CCPoint normalToCartesian(int x, int y) {
    return ccp(x*23, y*17.25);
}
CCPoint affineToNormal(int x, int y) {
    return ccp(x-y, x+y);
}

NewWorld *NewWorld::create(int n) {
    NewWorld *p = new NewWorld();
    p->init(n);
    p->autorelease();
    return p;
}
bool NewWorld::init(int n) {
    maxSearchNum = 3;
    searchNum = 0;
    searchYet = false;
    cellNum = n;// 地图加上两条保护边 或者多加几个保护范围
    calGrid = NULL;
    performance = false;
    benchmark = NULL;
    bigCoff = 8;
    tempBuildId = -1;
    cellSize = 100;

    initCell();
    return true;
}

//得到cell 对应的编号
int NewWorld::getKey(int x, int y) {
    return x*(cellNum+2)+y;
}
CCPoint NewWorld::getXY(int k) {
    return ccp(k/(cellNum+2), k%(cellNum+2));
}
void NewWorld::adjustStartPoint() {
    startPoint.x = startPoint.x < 1 ?  1 : startPoint.x;
    startPoint.y = startPoint.y < 1 ?  1 : startPoint.y;

    startPoint.x = startPoint.x > cellNum ?  cellNum : startPoint.x;
    startPoint.y = startPoint.y > cellNum ?  cellNum : startPoint.y;
}

NewWorld::~NewWorld() {
    delete [] cells;
    //ht_destroy(buildInfo);
    delete buildInfo;
}
void NewWorld::initCell() {
    cells = new Cell[(cellNum+2)*(cellNum+2)];
    //buildInfo = ht_init(300, NULL);
    buildInfo = new map<int, BuildingInfo>();

    for(int i = 0; i <= cellNum+1; i++) {
        int key;
        Cell *c;
        key = getKey(0, i); 
        c = &cells[key];
        c->state = 1;

        key = getKey(i, 0); 
        c = &cells[key];
        c->state = 1;

        key = getKey(cellNum+1, i); 
        c = &cells[key];
        c->state = 1;

        key = getKey(i, cellNum+1); 
        c = &cells[key];
        c->state = 1;
    }
}
//插入建筑距离信息
void insertSort(vector<BuildRange> *prevGrid, BuildRange *br) {
    int len = prevGrid->size();
    for(int i = 0; i < len; i++) {
        if((*prevGrid)[i].dist >= br->dist) {
            prevGrid->insert(prevGrid->begin()+i, *br);
            return;
        }
    }
    prevGrid->push_back(*br);
}

void NewWorld::setBuild(int x, int y, int size, int btype, int bid) {
    //CCLog("setBuild in NewWorld");
    float halfSize = size/2.0;
    float cx = x+size/2.0;
    float cy = y+size/2.0;
    //intInsert(buildInfo, bid, (BuildingInfo){x, y, size, btype, bid, cx, cy});
    BuildingInfo b = {x, y, size, btype, bid, cx, cy};
    (*buildInfo)[bid] = b;
    if(typeNum.count(btype) == 0) {
        typeNum[btype] = 1;
    } else {
        typeNum[btype]++;
    }

    for(int i=x; i <= x+size-1; i++) {
        for(int j=y; j <= y+size-1; j++) {
            int key = getKey(i, j);
            cells[key].state = 2;
            cells[key].bid = bid;
        }
    }


    //排序消耗的时间么？
    for(int i = x-6; i <= x+size+5; i++) {
        for(int j = y-6; j <= y+size+5; j++) {
            if(i >= 0 && i <= cellNum+1 && j >= 0 && j <= cellNum+1) {
                int key = getKey(i, j);
                Cell *cell = &cells[key];
                vector<BuildRange> *prevGrid = &(cell->prevGrid);
                if(i >= x && i < x+size && j >= y && j < y+size) {
                    BuildRange br = {bid, 0, btype};
                    insertSort(&cells[key].prevGrid, &br);
                } else {
                    float dx = fabs(cx-(i+0.5));
                    float dy = fabs(cy-(j+0.5));
                    float dis = 0;
                    if(dx <= halfSize) {
                        dis = max(dy-halfSize-0.5, 0);
                    } else if(dy <= halfSize) {
                        dis = max(dx-halfSize-0.5, 0);
                    } else {
                        float ex = dx-halfSize;
                        float ey = dy-halfSize;
                        dis = max(sqrtf(ex*ex+ey*ey)-0.5, 0);
                    }
                    BuildRange br = {bid, dis, btype};
                    insertSort(&cells[key].prevGrid, &br);
                }
            }
        }
    }

    //showGrid();
}

void NewWorld::clearBuild(int x, int y, int size, int btype, int bid) {
    //CCLog("clearBuild in NewWorld");
    //intRemove(buildInfo, bid);
    buildInfo->erase(bid);
    for(int i=x; i <= x+size-1; i++) {
        for(int j=y; j <= y+size-1; j++) {
            cells[getKey(i, j)].state = 0;
            cells[getKey(i, j)].bid = -1;
        }
    }
    typeNum[btype]--;

    for(int i = x-6; i <= x+size+5; i++) {
        for(int j = y-6; j <= y+size+5; j++) {
            if(i >= 0 && i <= cellNum+1 && j >= 0 && j <= cellNum+1) {
                int key = getKey(i, j);
                Cell *cell = &cells[key];
                vector<BuildRange> *prevGrid = &(cell->prevGrid);
                for(int k = 0; k < prevGrid->size(); k++) {
                    if((*prevGrid)[k].bid == bid) {
                        prevGrid->erase(prevGrid->begin()+k);
                        break;
                    }
                }
            }
        }
    }

}

void NewWorld::calcBusinessG(int x, int y) {
    Cell *data = &cells[getKey(x, y)];
    CCPoint p = getXY(data->parent);
    int difX = fabs(p.x-x);
    int difY = fabs(p.y-y);
    int dist = 10;
    if(difX > 0 && difY > 0)
        dist = 14;


    //该路径到达的目的建筑物和我的相同
    if(data->isPath && tempBuildId != -1 && data->curTarget == tempBuildId) {
        dist = 1;
    }

    data->gScore = cells[data->parent].gScore+dist;
}
//爆炸人不用复用路径
//要尽量走直线的
void NewWorld::calcWallG(int x, int y) {
    Cell *data = &cells[getKey(x, y)];
    CCPoint p = getXY(data->parent);
    int difX = fabs(p.x-x);
    int difY = fabs(p.y-y);
    int dist = 10;
    if(difX > 0 && difY > 0)
        dist = 14;
    //专挑城墙路行走
    //该路径到达的目的建筑物和我的相同

    //集中攻击一处城墙
    if(data->state == 3) {
        if(data->wallPath)
            dist = 1;
    }
    //建筑物里面
    else if(data->state == 2) {
        dist = 500;
    }
    //不用考虑爆炸人重叠问题 尽量炸一个城墙
    //dist += min(data->pathCount*10, 40);
    data->gScore = cells[data->parent].gScore+dist;
}
void NewWorld::calcG(int x, int y) {
    Cell *data = &cells[getKey(x, y)];
    CCPoint p = getXY(data->parent);
    int difX = fabs(p.x-x);
    int difY = fabs(p.y-y);
    int dist = 10;
    if(difX > 0 && difY > 0)
        dist = 14;

    //地面单位考虑 建筑物 城墙
    if(unitType == 1) {
        if(data->state == 2) {
            dist = 500;
        //根据剩余生命值决定 
        //根据攻打的人数决定 life/number/10 = cost
        }else if(data->state == 3) {
            if(data->wallPath) {
                struct timeval start;
                gettimeofday(&start, NULL);
                long s = start.tv_sec*1000000+start.tv_usec;
                s /= 1000;//ms 毫秒
                //城墙路径超时不再攻打
                if(s - data->wallTime >= 1000) {
                    data->wallPath = false;
                    data->wallTime = 0;
                    dist = 100;
                }else {
                    dist = 1;
                }
            }else
                dist = 100;
        }
    } 
    //该路径到达的目的建筑物和我的相同
    if(data->isPath) {
        struct timeval start;
        gettimeofday(&start, NULL);
        long s = start.tv_sec*1000000+start.tv_usec;
        s /= 1000;//ms 毫秒 超过5000ms时间
        //路径超时失效
        if(s-data->pathTime >= 1000) {
            data->isPath = false;
        }
        if(data->isPath && endTarget != NULL && data->curTarget == endTarget->bid) {
            dist = 1;
        }
    }

    dist += min(data->pathCount*10, 40);
    data->gScore = cells[data->parent].gScore+dist;
}
void NewWorld::calcBusinessH(int x, int y) {
    Cell *data = &cells[getKey(x, y)];
    if(endTarget != NULL) {
        int dx = fabs(endPoint.x-x);
        int dy = fabs(endPoint.y-y);
        data->hScore = (dx+dy)*10;
    } else {
        data->hScore = 1;
    }
}
void NewWorld::calcH(int x, int y) {
    Cell *data = &cells[getKey(x, y)];
    if(endTarget != NULL) {
        int dx = fabs(endPoint.x-x);
        int dy = fabs(endPoint.y-y);
        data->hScore = (dx+dy)*10;
    } else {
        data->hScore = 1;
    }
}

void NewWorld::findFavoriteEndPoint(){
    float minDistance = 1000000;
    BuildingInfo *target = NULL;
    map<int, BuildingInfo>::iterator it;
    for(it = buildInfo->begin(); it != buildInfo->end(); it++) {
        BuildingInfo *b = &(it->second);
        float dx = fabs(b->cx-startPoint.x);
        float dy = fabs(b->cy-startPoint.y);
        if(dx+dy < minDistance && b->btype == favorite) {
            minDistance = dx+dy;
            target = b; 
        }
    }
    endTarget = target;
    if(target != NULL) {
        endPoint = ccp(target->cx, target->cy);
    }
}
//没有城墙则攻击建筑物
void NewWorld::findEndWall(){
	if(!walls.empty()) {
        float minDistance = 1000000;
        BuildingInfo *target = NULL;
        map<int, BuildingInfo>::iterator it;
        for(it = walls.begin(); it != walls.end(); it++) {
            BuildingInfo *b = &(it->second);
            float dx = fabs(b->cx-startPoint.x);
            float dy = fabs(b->cy-startPoint.y);
            if(dx+dy < minDistance) {
                minDistance = dx+dy;
                target = b; 
            }
        }
        endTarget = target;
        if(target != NULL) {
            endPoint = ccp(target->cx, target->cy);
        }
	}else {
        findEndPoint();
	}
}
//searchAttack 之间首先清理endTarget = NULL
//接着findEndPoint

//根据startPoint 计算最近的 建筑物
//all building Info
void NewWorld::findEndPoint() {
    //hashtab_iter_t ii;
    //ht_iter_init(buildInfo, &ii);
    float minDistance = 1000000;
    BuildingInfo *target = NULL;
    map<int, BuildingInfo>::iterator it;
    for(it = buildInfo->begin(); it != buildInfo->end(); it++) {
        BuildingInfo *b = &(it->second);
        float dx = fabs(b->cx-startPoint.x);
        float dy = fabs(b->cy-startPoint.y);
        if(dx+dy < minDistance) {
            minDistance = dx+dy;
            target = b; 
        }
    }
    endTarget = target;
    if(target != NULL) {
        endPoint = ccp(target->cx, target->cy);
    }
}
void NewWorld::calcF(int x, int y) {
    Cell *data = &cells[getKey(x, y)];
    data->fScore = data->gScore+data->hScore;
}

void NewWorld::pushQueue(int x, int y) {
    int key = getKey(x, y);
    int fScore = cells[key].fScore;
    openList->push(fScore);
    if(pqDict->count(fScore) == 0) {
        vector<int> v;
        (*pqDict)[fScore] = v;
    }
    (*pqDict)[fScore].push_back(key);
}
void NewWorld::checkBusinessNeibor(int x, int y) {
    int neibors[][2] = {
        {x-1, y-1},
        {x, y-1},
        {x+1, y-1},
        {x+1, y},
        {x+1, y+1},
        {x, y+1},
        {x-1, y+1},
        {x-1, y}
    };
    //可能fscore 是之前寻路留下来的但是 openlist 中是没有的
    //fscore 对应的 vector 为什么只有1个possible
    for(int i = 0; i < 8; i++) {
        int nx = neibors[i][0];
        int ny = neibors[i][1];
        int key = getKey(nx, ny);
        //state == 1控制搜索范围不能越界 不能穿透建筑物
        if(closedList->count(key) == 0 && cells[key].state != 1 && cells[key].state != 2) {
            int fs = cells[key].fScore;
            bool inOpen = false;
            if(pqDict->count(fs) > 0) {
                vector<int> *newPossible = &(*pqDict)[fs];
                //CCLog("fs size %d %d", fs, newPossible->size());
                for(int k = 0; k < newPossible->size(); k++) {
                    //CCLog("new Possible %d %d", key, (*newPossible)[k]);
                    if((*newPossible)[k] == key) {
                        inOpen = true;
                        break;
                    }
                }
            }
            //CCLog("cells state %d %d %d %d", nx, ny, fs, inOpen);
            if(inOpen) {
                int oldParent = cells[key].parent;
                int oldGScore = cells[key].gScore;
                int oldHScore = cells[key].hScore;
                int oldFScore = cells[key].fScore;
                cells[key].parent = getKey(x, y);
                calcBusinessG(nx, ny);
                    
                if(cells[key].gScore >= oldGScore) {
                    cells[key].parent = oldParent;
                    cells[key].gScore = oldGScore;
                    cells[key].hScore = oldHScore;
                    cells[key].fScore = oldFScore;
                } else {
                    calcBusinessH(nx, ny);
                    calcF(nx, ny);
                    vector<int> *oldPossible = &(*pqDict)[oldFScore];
                    for(int k = 0; k < oldPossible->size(); k++) {
                        if((*oldPossible)[k] == key) {
                            oldPossible->erase(oldPossible->begin()+k);
                            break;
                        }
                    }
                    pushQueue(nx, ny);
                }
            } else {
                cells[key].parent = getKey(x, y);
                calcBusinessG(nx, ny);
                calcBusinessH(nx, ny);
                calcF(nx, ny);
                pushQueue(nx, ny);
            }

        }
    }
    closedList->insert(getKey(x, y));
}
void NewWorld::checkNeibor(int x, int y, MyCalc cg, MyCalc ch) {
    //CCLog("checkNeibor %d %d", x, y);
    int neibors[][2] = {
        {x-1, y-1},
        {x, y-1},
        {x+1, y-1},
        {x+1, y},
        {x+1, y+1},
        {x, y+1},
        {x-1, y+1},
        {x-1, y}
    };
    //可能fscore 是之前寻路留下来的但是 openlist 中是没有的
    //fscore 对应的 vector 为什么只有1个possible
    for(int i = 0; i < 8; i++) {
        int nx = neibors[i][0];
        int ny = neibors[i][1];
        int key = getKey(nx, ny);
        //state == 1控制搜索范围不能越界
        if(closedList->count(key) == 0 && cells[key].state != 1) {//不能穿透建筑物 如果士兵陷入建筑物内部也可以走出来
            int fs = cells[key].fScore;
            bool inOpen = false;
            if(pqDict->count(fs) > 0) {
                vector<int> *newPossible = &(*pqDict)[fs];
                //CCLog("fs size %d %d", fs, newPossible->size());
                for(int k = 0; k < newPossible->size(); k++) {
                    //CCLog("new Possible %d %d", key, (*newPossible)[k]);
                    if((*newPossible)[k] == key) {
                        inOpen = true;
                        break;
                    }
                }
            }
            //CCLog("cells state %d %d %d %d", nx, ny, fs, inOpen);
            if(inOpen) {
                int oldParent = cells[key].parent;
                int oldGScore = cells[key].gScore;
                int oldHScore = cells[key].hScore;
                int oldFScore = cells[key].fScore;
                cells[key].parent = getKey(x, y);
                ((*this).*cg)(nx, ny);
                    
                if(cells[key].gScore >= oldGScore) {
                    cells[key].parent = oldParent;
                    cells[key].gScore = oldGScore;
                    cells[key].hScore = oldHScore;
                    cells[key].fScore = oldFScore;
                } else {
                    ((*this).*ch)(nx, ny);
                    calcF(nx, ny);
                    vector<int> *oldPossible = &(*pqDict)[oldFScore];
                    for(int k = 0; k < oldPossible->size(); k++) {
                        if((*oldPossible)[k] == key) {
                            oldPossible->erase(oldPossible->begin()+k);
                            break;
                        }
                    }
                    pushQueue(nx, ny);
                }
            } else {
                cells[key].parent = getKey(x, y);
                (this->*cg)(nx, ny);
                (this->*ch)(nx, ny);
                calcF(nx, ny);
                pushQueue(nx, ny);
            }

        }
    }
    closedList->insert(getKey(x, y));
}

//得到路径需要确保p 总是大于 >0
//SearchResult 中拼装
MyVector *NewWorld::getPath(int p, int curTarget) {
    MyVector *path = new MyVector();
    struct timeval start;
    gettimeofday(&start, NULL);
    long s = start.tv_sec*1000000+start.tv_usec;
    s /= 1000;//ms 毫秒
    while(true) {
        CCPoint xy = getXY(p);
        path->path.push_back(xy);
        //第一次作为路径 更新路径时间
        if(!cells[p].isPath)
            cells[p].pathTime = s; 
        cells[p].isPath = true;
        cells[p].curTarget = curTarget;

        if(xy.x == startPoint.x && xy.y == startPoint.y)
            break;
        p = cells[p].parent;
    }
    return path;
}

void NewWorld::showGrid() {
    if(calGrid != NULL) {
        calGrid->removeFromParent();
    }
    CCNode *ground = getParent()->getChildByTag(1024);

    calGrid = CCNode::create();
    ground->addChild(calGrid, 10000);
    int zx = 2080;
    int zy = 195;

    //显示建筑物网格范围
    //显示路径信息
    for(int x=1; x <= cellNum; x++) {
        for(int y=1; y <= cellNum; y++) {
            int key = getKey(x, y);
            if(cells[key].state == 2) {
                CCSprite *temp = CCSprite::create("block.png");
                temp->setOpacity(128);
                CCSize cs = temp->getContentSize();
                temp->setScaleX(46/cs.width);
                temp->setScaleY(34.5/cs.height);
                calGrid->addChild(temp);
                CCPoint nxy = affineToNormal(y, x);
                CCPoint pxy = normalToCartesian(nxy.x, nxy.y);
                temp->setPosition(ccp(pxy.x+zx, pxy.y+zy+17.25));
                temp->setColor(ccc3(255, 255, 255));
            } else if(cells[key].fScore > 0) {
                CCSprite *temp = CCSprite::create("block.png");
                temp->setOpacity(128);
                CCSize cs = temp->getContentSize();
                temp->setScaleX(46/cs.width);
                temp->setScaleY(34.5/cs.height);
                calGrid->addChild(temp);
                CCPoint nxy = affineToNormal(y, x);
                CCPoint pxy = normalToCartesian(nxy.x, nxy.y);
                temp->setPosition(ccp(pxy.x+zx, pxy.y+zy+17.25));
                temp->setColor(ccc3(0, 0, 0));

                if(cells[key].pathCount > 0) {
                    char w[300];
                    Cell *d = &cells[key];
                    sprintf(w, "%d", d->pathCount);
                    CCLabelTTF *word = CCLabelTTF::create(w, "Arial", 50);
                    word->setColor(ccc3(0, 0, 0));
                    word->setPosition(ccp(23, 17.5));
                    word->setAnchorPoint(ccp(0.5, 0.5));
                    temp->addChild(word);
                }

                /*
                char w[300];
                Cell *d = &cells[key];
                sprintf(w, "%d %d %d", d->gScore, d->hScore, d->fScore);
                CCLabelTTF *word = CCLabelTTF::create(w, "Arial", 20);
                word->setColor(ccc3(255, 255, 255));
                word->setPosition(ccp(23, 17.5));
                word->setAnchorPoint(ccp(0.5, 0.5));
                temp->addChild(word);
                */
            }
            if(cells[key].isPath) {
                CCSprite *temp = CCSprite::create("block.png");
                temp->setOpacity(128);
                CCSize cs = temp->getContentSize();
                temp->setScaleX(46/cs.width);
                temp->setScaleY(34.5/cs.height);
                calGrid->addChild(temp);
                CCPoint nxy = affineToNormal(y, x);
                CCPoint pxy = normalToCartesian(nxy.x, nxy.y);
                temp->setPosition(ccp(pxy.x+zx, pxy.y+zy+17.25));
                temp->setColor(ccc3(0, 255, 0));

                char w[300];
                Cell *d = &cells[key];
                sprintf(w, "%d %d", d->curTarget, tempBuildId);
                CCLabelTTF *word = CCLabelTTF::create(w, "Arial", 30);
                word->setColor(ccc3(0, 0, 0));
                word->setPosition(ccp(23, 17.5));
                word->setAnchorPoint(ccp(0.5, 0.5));
                temp->addChild(word);
            }
            if(cells[key].wallPath) {
                CCSprite *temp = CCSprite::create("block.png");
                temp->setOpacity(128);
                CCSize cs = temp->getContentSize();
                temp->setScaleX(46/cs.width);
                temp->setScaleY(34.5/cs.height);
                calGrid->addChild(temp);
                CCPoint nxy = affineToNormal(y, x);
                CCPoint pxy = normalToCartesian(nxy.x, nxy.y);
                temp->setPosition(ccp(pxy.x+zx, pxy.y+zy+17.25));
                temp->setColor(ccc3(0, 0, 255));
            

            }

            if(cells[key].isStopGrid) {
                CCSprite *temp = CCSprite::create("block.png");
                temp->setOpacity(128);
                CCSize cs = temp->getContentSize();
                temp->setScaleX(46/cs.width);
                temp->setScaleY(34.5/cs.height);
                calGrid->addChild(temp);
                CCPoint nxy = affineToNormal(y, x);
                CCPoint pxy = normalToCartesian(nxy.x, nxy.y);
                temp->setPosition(ccp(pxy.x+zx, pxy.y+zy+17.25));
                temp->setColor(ccc3(255, 0, 0));
            }
            vector<BuildRange> *pg = &cells[key].prevGrid;
            if(pg->size() > 0 && (*pg)[0].dist < 3) {
                CCSprite *temp = CCSprite::create("block.png");
                temp->setOpacity(128);
                CCSize cs = temp->getContentSize();
                temp->setScaleX(46/cs.width);
                temp->setScaleY(34.5/cs.height);
                calGrid->addChild(temp);
                CCPoint nxy = affineToNormal(y, x);
                CCPoint pxy = normalToCartesian(nxy.x, nxy.y);
                temp->setPosition(ccp(pxy.x+zx, pxy.y+zy+17.25));
                temp->setColor(ccc3(255/3*(3-(*pg)[0].dist), 0, 0));
            }

        }
    }
}
void NewWorld::adjustFavorite() {
}
void NewWorld::adjustEndPoint() {
}
void NewWorld::setGrids(int x, int y, int size, int bid) {
    float halfSize = size/2.0;
    float cx = x+halfSize;
    float cy = y+halfSize;
    BuildingInfo b = {x, y, size, 0, bid, cx, cy};
    walls[bid] = b;

	for(int i=1; i <= size; i++) {
		for(int j=1; j <= size; j++) {
            int key = getKey(x-1+i, y-1+j);
			cells[key].state = 3;
            cells[key].bid = bid;
        }
    }
    
}
void NewWorld::setObstacle(int x, int y, int size, int bid) {
	for(int i=1; i <= size; i++) {
		for(int j=1; j <= size; j++) {
            int key = getKey(x-1+i, y-1+j);
			cells[key].state = 1;
            cells[key].bid = bid;
        }
    }
}
void NewWorld::clearObstacle(int x, int y, int size){
	for(int i=1; i <= size; i++) {
		for(int j=1; j <= size; j++) {
            int key = getKey(x-1+i, y-1+j);
			cells[key].state = 0;
            cells[key].bid = -1;
        }
    }
}
void NewWorld::clearGrids(int x, int y, int size, int bid) {
	walls.erase(bid);
	for(int i=1; i <= size; i++) {
		for(int j=1; j <= size; j++) {
            int key = getKey(x-1+i, y-1+j);
			cells[key].state = 0;
            cells[key].bid = -1;
        }
    }
}

//startPoint 
//endPoint
//searchBusiness
SearchResult *NewWorld::searchBusiness() {
    //CCLog("searchBusiness");
    searchNum++;
    if(searchNum >= maxSearchNum)
        searchYet = true;
    SearchResult *result = new SearchResult();
    adjustStartPoint();
    openList = new priority_queue<int, vector<int>, greater<int> >();
    closedList = new set<int>();
    pqDict = new map<int, vector<int> >(); 
    
    cells[getKey(startPoint.x, startPoint.y)].gScore = 0;
    calcBusinessH(startPoint.x, startPoint.y);
    calcF(startPoint.x, startPoint.y);
    pushQueue(startPoint.x, startPoint.y);
    
    int lastPoint = -1;
    Cell *binfo = NULL;
    while(!openList->empty() ) {
        int fScore = openList->top();
        openList->pop();
        vector<int> *possible = &(*pqDict)[fScore];
        if(!possible->empty()) {
            int point = possible->back(); 
            possible->pop_back();
            CCPoint xy = getXY(point);
            if(xy.x == endPoint.x && xy.y == endPoint.y) {
                lastPoint = point;
                binfo = &cells[point];
                break;
            }
            checkBusinessNeibor(xy.x, xy.y);
        }
    }

    delete openList;
    delete closedList;
    delete pqDict;
    if(binfo != NULL) {
        MyVector *path = getPath(lastPoint, tempBuildId);//当前路径的攻击目标     
        path->reverse();
        result->path = path;
        result->bid = binfo->bid;
    }
    //showGrid();
    return result;
}

void NewWorld::updateSearchNum() {
    searchNum++;
    if(searchNum >= maxSearchNum)
        searchYet = true;
}
void NewWorld::initOpenList() {
    openList = new priority_queue<int, vector<int>, greater<int> >();
    closedList = new set<int>();
    pqDict = new map<int, vector<int> >(); 
}
void NewWorld::removeOpenList() {
    delete openList;
    delete closedList;
    delete pqDict;
}
//炸弹人寻路
SearchResult *NewWorld::searchWall() {
    updateSearchNum();
    SearchResult *result = new SearchResult();
    if(buildInfo->empty())
        return result;
    
    adjustStartPoint();
    //favorite = -1;
    //unitType = 1;
    //attackRange = 0.5f;//自爆人的攻击范围
    initOpenList();
    //findEndPoint();
    findEndWall();
    bool hasWall = !walls.empty();


    cells[getKey(startPoint.x, startPoint.y)].gScore = 0;
    calcH(startPoint.x, startPoint.y);
    calcF(startPoint.x, startPoint.y);
    pushQueue(startPoint.x, startPoint.y);

    //如果当前点 状态是 0 1 2building 3wall 建筑物城墙
    int lastPoint = -1;
    BuildRange *binfo = NULL;
    int bid = -1;
    while(!openList->empty() ) {
        int fScore = openList->top();
        openList->pop();
        vector<int> *possible = &(*pqDict)[fScore];
        if(!possible->empty()) {
            int point = possible->back(); 
            possible->pop_back();
            CCPoint xy = getXY(point);
            //当前点是城墙
			if(cells[point].state == 3) {
                lastPoint = point;
                bid = cells[point].bid;
                //binfo = walls[];
                break;
            //当前点是建筑物 且没有城墙目标
			} else if(!hasWall){
                vector<BuildRange> *prevGrid = &cells[point].prevGrid;
                if(!prevGrid->empty() && (*prevGrid)[0].dist <= attackRange) {
                    lastPoint = point;
                    binfo = &(*prevGrid)[0];
					bid = binfo->bid;
                    break;
                }
			}
            checkNeibor(xy.x, xy.y, &NewWorld::calcWallG, &NewWorld::calcH);
        }
    }
    removeOpenList();
    
    if(bid != -1) {
        MyVector *path = getPath(lastPoint, bid);//当前路径的攻击目标     
        //自动reverse 路径
        WallResult ret = checkWall(path);
        if(ret.findWall) {
            findWallPath(&ret);
            result->path = ret.path;
            result->bid = ret.wallObj;
        } else {
            result->path = ret.path;
            result->bid = bid;
        }
    }
    //showGrid();
    return result;
}

//返回路径和攻击目标的编号 
SearchResult *NewWorld::searchAttack() {
    struct timeval start;
    gettimeofday(&start, NULL);
    
    searchNum++;
    if(searchNum >= maxSearchNum)
        searchYet = true;
    SearchResult *result = new SearchResult();
    if(buildInfo->empty())
        return result;

    adjustStartPoint();
    //没有最喜欢的建筑物
    if(favorite != -1) {
        if(typeNum.count(favorite) == 0 || typeNum[favorite] == 0)
            favorite = -1;
    }
    //CCLog("favorite %d", favorite);

    openList = new priority_queue<int, vector<int>, greater<int> >();
    closedList = new set<int>();
    pqDict = new map<int, vector<int> >(); 
    if(favorite == -1)
        findEndPoint();
    else 
        findFavoriteEndPoint();

    cells[getKey(startPoint.x, startPoint.y)].gScore = 0;
    calcH(startPoint.x, startPoint.y);
    calcF(startPoint.x, startPoint.y);
    pushQueue(startPoint.x, startPoint.y);

    //如果当前点 状态是 0 1 2building 3wall 建筑物城墙
    int lastPoint = -1;
    //Cell *binfo = NULL;
    BuildRange *binfo = NULL;
    while(!openList->empty() ) {
        int fScore = openList->top();
        openList->pop();
        vector<int> *possible = &(*pqDict)[fScore];
        //CCLog("openList %d", fScore);
        if(!possible->empty()) {
            int point = possible->back(); 
            possible->pop_back();
            CCPoint xy = getXY(point);
            //CCLog("possible pop %d", point);
            //if(cells[point].state == 2 || cells[point].state == 3) {
            vector<BuildRange> *prevGrid = &cells[point].prevGrid;
            if(favorite == -1) {
                if(!prevGrid->empty() && (*prevGrid)[0].dist <= attackRange) {
                    lastPoint = point;
                    binfo = &(*prevGrid)[0];
                    break;
                }
            } else {
                //寻找攻击范围内的最喜欢的建筑物
                int len = prevGrid->size();
                bool find = false;
                for(int i=0; i < len; i++) {
                    BuildRange *br = &(*prevGrid)[i];
                    if(br->dist <= attackRange && br->btype == favorite) {
                        lastPoint = point;
                        binfo = br;
                        find = true;
                        break;
                    } else if(br->dist > attackRange){
                        break;
                    }
                }
                if(find)
                    break;
            }
            //CCLog("begin checkNeibor");
            checkNeibor(xy.x, xy.y, &NewWorld::calcG, &NewWorld::calcH);
        }
    }

    delete openList;
    delete closedList;
    delete pqDict;
    //找到目标建筑物信息 则可以攻击 返回路径
    if(binfo != NULL) {
        //目标建筑物
        result->realTarget = binfo->bid;
        MyVector *path = getPath(lastPoint, binfo->bid);//当前路径的攻击目标     
        //自动reverse 路径
        WallResult ret = checkWall(path);
        if(ret.findWall) {
            findWallPath(&ret);
            result->path = ret.path;
            result->bid = ret.wallObj;
        } else {
            result->path = ret.path;
            result->bid = binfo->bid;
        }
    }
    struct timeval end;
    gettimeofday(&end, NULL);
    long o = end.tv_sec*1000000+end.tv_usec;
    long s = start.tv_sec*1000000+start.tv_usec;
    long diff = o-s;
    if(performance) {
        if(benchmark != NULL)
            benchmark->removeFromParent();
        benchmark = CCNode::create();

        getParent()->addChild(benchmark, 100000);
        char word[300];
        sprintf(word, "%.4f", diff/1000000.0);
        CCLabelTTF *t = CCLabelTTF::create(word, "Arial", 20);
        benchmark->addChild(t);

        t->setPosition(ccp(200, 200));
    }

    //showGrid();
    return result;
}
//逆序路径 逐步加入路径点 释放原来的路径点
WallResult NewWorld::checkWall(MyVector *path) {
    WallResult ret = {false, NULL, 0, 0, -1};
    //空军单位不检测城墙
    if(unitType == 2) {
        path->reverse();
        ret.path = path;
        return ret;
    }

    struct timeval start;
    gettimeofday(&start, NULL);
    long s = start.tv_sec*1000000+start.tv_usec;
    s /= 1000;//ms 毫秒

    MyVector *temp = new MyVector();
    int i;
    vector<CCPoint> *realPath = &path->path;
	int len = realPath->size();
    for(i=len-1; i >= 0; i--) {
        temp->path.push_back((*realPath)[i]);
        int key = getKey((*realPath)[i].x, (*realPath)[i].y);
        Cell *data = &cells[key];
        //本身在城墙里面不考虑
        if(data->state == 3 && i != len-1) {
            ret.findWall = true;
            ret.path = temp;
            ret.wallX = path->path[i].x;
            ret.wallY = path->path[i].y;
            ret.wallObj = data->bid;
            if(data->wallPath == false) {
                data->wallPath = true;
                data->wallTime = s; 
            }
            break;
        }
    }
    delete path;
    ret.path = temp;
    //CCLog("checkWall %d %d %d %d %d", ret.findWall, temp->path.size(), ret.wallX, ret.wallY, ret.wallObj);
    return ret;
}
//startPoint 是士兵起始位置
//调整了result 的 
void NewWorld::findWallPath(WallResult *result) {
    int key = getKey(result->wallX, result->wallY);
    int solX = startPoint.x;
    int solY = startPoint.y;
    int dx = solX-result->wallX;
    int dy = solY-result->wallY;
    int wpx = result->wallX;
    int wpy = result->wallY;
    vector<CCPoint> *path = &result->path->path;
    //路径长度 == 2 起点 和 城墙终点 但是不能和城墙重叠
    if(dx*dx+dy*dy <= attackRange*attackRange || path->size() <= 2) {
        path->erase(path->begin()+1, path->end());
    } else {
        //终点所在path的编号
        int stopGrid = max(result->path->getLength()-2, 0);
        for(int i = stopGrid-1; i >= 0; i--) {
            CCPoint xy = result->path->objectAt(i);
            int dx = xy.x-wpx;
            int dy = xy.y-wpy;
            if(dx*dx+dy*dy > attackRange*attackRange) {
                stopGrid = min(i+1, stopGrid);
                break;
            }
        }
        for(int i = path->size()-1; i >= stopGrid+1; i--) {
            path->pop_back();
        }
        cells[getKey((*path)[stopGrid].x, (*path)[stopGrid].y)].isStopGrid = true;
    }
}
void NewWorld::addPathCount(int x, int y){
    int key = getKey(x, y);
    cells[key].pathCount++;
}   
void NewWorld::minusPathCount(int x, int y) {
    int key = getKey(x, y);
    int old = cells[key].pathCount;
    if(old > 0) {
        cells[key].pathCount--;
    }
}

//清除寻路状态 每帧
void NewWorld::clearSearchYet() {
    /*
    searchNum--;
    if(searchNum <= 0) {

    }
    */
    searchYet = false;
    searchNum = 0;
}
//游戏开始初始化路径信息
void NewWorld::initPath() {
    int totalX = ceilf(cellNum/bigCoff);
    int totalY = ceilf(cellNum/bigCoff);
    for(int i=1; i <= totalX; i++) {
        for(int j=1; j<= totalY; j++) {
            CCPoint bxy = getBigCenter(i, j);
            startPoint = bxy;
            attackRange = 0.5;
            favorite = -1;
            unitType = 1;
            searchAttack();
        }
    }
}
CCPoint NewWorld::getBigCenter(int x, int y){
    return ccp((x-1)*bigCoff+1+bigCoff/2.0f, (y-1)*bigCoff+1+bigCoff/2.0f);
}

bool NewWorld::checkBlock(int x, int y) {
    return cells[getKey(x, y)].state != 0;
}
