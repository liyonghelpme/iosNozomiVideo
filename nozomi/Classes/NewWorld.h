#ifndef __NEWWORLD_H__
#define __NEWWORLD_H__
#include "cocos2d.h"
//#include "hashtab.h"
#include "vector"
#include "queue"
#include "set"
#include <map>


using namespace cocos2d;
using namespace std;
class MyVector{
public:
    vector<CCPoint> path;
    CCPoint objectAt(int i) {
        return path[i];
    }
    int getLength() {
        return path.size();
    }
    void reverse() {
        int i, j;
        for(i=0, j=path.size()-1; i<j; i++, j--) {
            CCPoint temp = path[i];
            path[i] = path[j];
            path[j] = temp;
        }
    }
};
//紧密属于world 若是lua 需要 则要转化成lua table 来处理
struct BuildingInfo {
    int x, y, size, btype, bid;
    float cx, cy;
};
class SearchResult {
public:
    MyVector *path;
    int bid;
    int realTarget;
    SearchResult() {
        path = NULL;
        bid = -1;
        realTarget = -1;
    }
    ~SearchResult() {
        delete path;
    }
};
struct BuildRange {
    int bid;
    float dist;
    int btype;
};
class Cell {
public:
    int state;//0 free 1 solid 2 building 3 wall
    int fScore;
    int gScore;
    int hScore;
    int parent;
    int bid;
    bool isPath;
    bool wallPath;
    bool isStopGrid;
    int pathCount;
    vector<BuildRange> prevGrid;
    int curTarget;
    long pathTime;
    long wallTime;
    Cell() {
        state = 0;
        fScore = 0;
        gScore = 0;
        hScore = 0;
        parent = -1;
        isPath = false;
        wallPath = false;
        isStopGrid = false;
        pathCount = 0;
        curTarget = -1;
        pathTime = 0;
        wallTime = 0;
    }
};
//没有复制数据 直接返回value 可以修改
/*
BuildingInfo *intSearch(hashtab_t *h, int k);
void *intInsert(hashtab_t *h, int k, BuildingInfo *b);
void intRemove(hashtab_t *h, int k);
*/

struct WallResult{
    bool findWall;
    MyVector *path;
    int wallX, wallY;
    int wallObj;
};

class NewWorld : public CCNode {
public:
    typedef void (NewWorld::*MyCalc)(int, int);

    ~NewWorld();
    static NewWorld *create(int n);
    bool init(int n);
    
    void setBuild(int x, int y, int size, int btype, int bid);
    void clearBuild(int x, int y, int size, int btype, int bid);
    void setGrids(int x, int y, int size, int bid);
    void clearGrids(int x, int y, int size, int bid);
    void setObstacle(int x, int y, int size, int bid);
    void clearObstacle(int x, int y, int size);

    SearchResult *searchAttack();
    SearchResult *searchBusiness();
    SearchResult *searchWall();

    void initPath();

    void addPathCount(int x, int y);
    void minusPathCount(int x, int y);

    MyVector *getPath(int, int);
    
    CCPoint startPoint;
    CCPoint endPoint;
    int tempBuildId;

    //hashtab_t *buildInfo; 

    float attackRange;
    int favorite;
    int unitType;


    bool searchYet;

    void clearSearchYet();

    map<int, int> typeNum;

    priority_queue<int, vector<int>, greater<int> > *openList;
    set<int> *closedList;
    map<int, vector<int> > *pqDict; //fscore --> vector<int>
    void showGrid(); 

    void adjustFavorite();
    void adjustEndPoint();
    WallResult checkWall(MyVector *path);
    void findWallPath(WallResult *);
    float cellSize;

    bool checkBlock(int x, int y);
private:
    bool performance;
    CCNode *benchmark;
    int bigCoff;
    CCPoint getBigCenter(int, int);

    void calcG(int , int);
    void calcH(int , int);
    void calcF(int , int);
    
    void calcBusinessG(int, int);
    void calcBusinessH(int, int);

    void calcWallG(int, int);

    void pushQueue(int x, int y);
    void checkNeibor(int x, int y, MyCalc cg, MyCalc ch);
    void checkBusinessNeibor(int, int);
    void adjustStartPoint();

    void findEndPoint();
    void findFavoriteEndPoint();

    int getKey(int, int);
    CCPoint getXY(int);
    void initCell();

    //直接加在自身节点上即可 但是不能和gound 一起运动
    //得到ground即可 TAG
    CCNode *calGrid;

    int cellNum;
    Cell *cells;

    int maxSearchNum;
    int searchNum;

    void updateSearchNum();
    void initOpenList();
    void removeOpenList();

    map<int, BuildingInfo > *buildInfo;
    BuildingInfo *endTarget;

    map<int, BuildingInfo> walls;
    void findEndWall();
};
#endif
