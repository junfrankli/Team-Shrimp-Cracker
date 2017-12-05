import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.Rectangle2D;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashSet;
import java.util.List;

import javax.swing.JFrame;
import javax.swing.JPanel;


public class Maze extends JPanel{
	private List<Object> shapes = new ArrayList<>();
	 public static final int WIDTH = 500;
	 public static final int HEIGHT = 500;



	 public Maze(int[][] maze, int[] currPos){
	        setPreferredSize(new Dimension(WIDTH, HEIGHT));
	        drawMaze(maze, currPos);   
	 }
	 
	 

	 public static void main(String[] args){
		 JFrame frame = new JFrame();
		 int[][] maze = generateMaze();
		 int[] currPos = new int[2];
		 currPos[0] = 0;
		 currPos[1] = 0;
		 frame.add(new Maze(maze, currPos));
		 frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	         frame.pack();
	         frame.setLocationRelativeTo(null);
	         frame.setVisible(true);	 
	 }
	 private static int[][] generateMaze() {
		 int[][] maze = new int[7][9];
		for (int x = 0; x<7; x++){
			for (int y = 0; y<9; y++){
				if (x%2 ==0 || y%2 ==0){
					maze[x][y]=0;
				}
				else{
					maze[x][y]=1;
				}
			}
		}
		return maze;	
	}
	public void drawMaze(int[][] maze, int[] currPosArray){
		 for (int i = 0; i<7; i++){
				for (int j = 0; j<9; j++){
					if ((i%2 == 1 && j%2 == 0) ||(i%2 == 0 && j%2 == 1) ){
						if(maze[i][j]==1){
							addWall(i,j);
						}
					}
					else if (i%2 ==0 && j%2 ==0){ //square location
						if (i==currPosArray[0] && j==currPosArray[1]){
							addCurrPos(i/2, j/2);
						}
						else{
							if (maze[i][j]==0){
								addUnvisited(i/2, j/2);			
							}
							else{
								addVisited(i/2, j/2);
							}
						}	
					}
				}
			}
	 }	
	 private void addVisited(int i, int j) {
		 int x = (int) Math.floor((i/4.0)*WIDTH);
			int y =  (int) Math.floor((j/5.0)*HEIGHT);
			int width = (int) Math.floor(WIDTH/4.0);
			int height = 	(int) Math.floor(HEIGHT/5.0);
			shapes.add(new Visited(x,y,width,height));
			repaint();
	}
	private void addUnvisited(int i, int j) {
		 int x = (int) Math.floor((i/4.0)*WIDTH);
			int y =  (int) Math.floor((j/5.0)*HEIGHT);
			int width = (int) Math.floor(WIDTH/4.0);
			int height = 	(int) Math.floor(HEIGHT/5.0);
			shapes.add(new Unvisited(x,y,width,height));
			repaint();
	}
	private void addCurrPos(int i, int j) {
		 int x = (int) Math.floor((i/4.0)*WIDTH);
			int y =  (int) Math.floor((j/5.0)*HEIGHT);
			int width = (int) Math.floor(WIDTH/4.0);
			int height = 	(int) Math.floor(HEIGHT/5.0);
			shapes.add(new CurrPos(x,y,width,height));
			repaint();
	}

	private void addWall(int i, int j) {
		int x,y,width,height;
		if (i%2 == 1){
			int relativeX = (i+1)/2;
			int relativeY = j/2;
			 width = (int) Math.floor((1/4.0)*(float)WIDTH*(0.1));
			 height = (int) Math.floor((1/5.0)*(float)HEIGHT);
			 x = (int) Math.floor(((relativeX/4.0)*WIDTH - width*0.5));
			 y = (int) (Math.floor((relativeY/5.0)*HEIGHT));
			
		}
		else{
			int relativeX = i/2;
			int relativeY = (j+1)/2;
			 width = (int) Math.floor((1/4.0)*WIDTH);
			 height = (int) Math.floor((1/5.0)*HEIGHT*(0.1));
			 x = (int) (Math.floor((relativeX/4.0)*WIDTH));
			 y = (int) Math.floor(((relativeY/5.0)*HEIGHT - height*.5));

		}		
		shapes.add(new Wall(x,y, width, height));
		repaint();
	}
	@Override
   protected void paintComponent(Graphics g) {
       super.paintComponent(g);
       for (Object s : shapes) {
           if (s instanceof Visited) {
               ((Visited) s).draw(g);
           } else if (s instanceof Unvisited) {
               ((Unvisited) s).draw(g);
           }
           else if (s instanceof CurrPos) {
               ((CurrPos) s).draw(g);
           }
           else if (s instanceof Wall) {
               ((Wall) s).draw(g);
           }
       }
   }
	public class Unvisited {
		int x;
		int y;
		int width;
		int height;
		
		public Unvisited(int x, int y, int width, int height){
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public void draw(Graphics g){
			Graphics2D g2d = (Graphics2D) g;
			Rectangle2D.Double grid = new Rectangle2D.Double(x,y,width,height);
			g2d.setColor(Color.lightGray);
			g2d.fill(grid);
		}
	}
	public class Visited {
		int x;
		int y;
		int width;
		int height;
		
		public Visited(int x, int y, int width, int height){
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public void draw(Graphics g){
			Graphics2D g2d = (Graphics2D) g;
			Rectangle2D.Double grid = new Rectangle2D.Double(x,y,width,height);
			g2d.setColor(Color.RED);
			g2d.fill(grid);
		}
	}
	public class Wall {
		int x;
		int y;
		int width;
		int height;
		
		public Wall(int x, int y, int width, int height){
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public void draw(Graphics g){
			Graphics2D g2d = (Graphics2D) g;
			Rectangle2D.Double grid = new Rectangle2D.Double(x,y,width,height);
			g2d.setColor(Color.BLACK);
			g2d.fill(grid);
		}
	}
	public class CurrPos {
		int x;
		int y;
		int width;
		int height;
		
		public CurrPos(int x, int y, int width, int height){
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public void draw(Graphics g){
			Graphics2D g2d = (Graphics2D) g;
			Rectangle2D.Double grid = new Rectangle2D.Double(x,y,width,height);
			g2d.setColor(Color.BLUE);
			g2d.fill(grid);
		}
	}
}
