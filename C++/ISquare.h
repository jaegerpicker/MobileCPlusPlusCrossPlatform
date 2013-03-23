//
// Created by shawn on 3/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//



#include <cstring>
#import <vector>

#ifndef __ISquare_H_
#define __ISquare_H_

using namespace std;
class ISquare {
public:
    virtual vector<float> calculateSquareVertices(int top, int bottom, int left, int right) = 0;
    virtual void rotateSquare(int dir, int angle) = 0;
    virtual void draw() = 0;
    virtual void ~ISquare();
};


#endif //__ISquare_H_
