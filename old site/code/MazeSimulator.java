import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Deque;
import java.util.HashSet;
import javax.swing.JFrame;


public class MazeSimulator {
	static int[][] Maze = new int[7][9];
	static int[] currPos = new int[2];
	static HashSet<String> frontierSet= new HashSet<String>();
	static Deque<int[]> visitedStack = new ArrayDeque<int[]>();
	static JFrame frame = new JFrame();
	static Maze oldMaze;
	
	public static void main(String []Args) throws InterruptedException{
		initializeCurrPos();
		frontierSet.add(Arrays.toString(currPos));
		setMaze();
		visitedStack.push(currPos);
		createJFrame();
		displayMaze();
		Thread.sleep(500);
		frame.setVisible(false);
		
	}
	private static void displayMaze() throws InterruptedException {
		DFS();
		
	}
	
	public static void DFS() throws InterruptedException {
		while (!frontierSet.isEmpty()){
			updateJFrame();
			Maze[currPos[0]][currPos[1]] = 2;
			visit();
			ArrayList<int[]> reachableCells = frontier();
			addFrontier(reachableCells);
			updateVisited(reachableCells);
			Thread.sleep(200);
			if (!frontierSet.isEmpty()){
				updateJFrame();
			}
		}
	}

	private static void updateJFrame(){
		 frame.remove(oldMaze);
		 Maze newMaze = new Maze(Maze, currPos);
		 frame.add(newMaze);
		 oldMaze = newMaze;
		 frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	     frame.pack();
	     frame.setVisible(true);
	}
	
	private static void createJFrame(){
		frame = new JFrame();
		oldMaze = new Maze(Maze, currPos);
		frame.add(oldMaze);
	}

	private static void setMaze() {
		for (int i = 0; i<7; i++){
			for (int j = 0; j<9; j++){
				Maze[i][j] = 0;
			}
		}
		Maze[5][3] = 1;
		Maze[6][3] = 1;
		Maze[3][6] = 1;
		Maze[5][2] = 1;
		Maze[0][2] = 1;
		Maze[3][2] = 1;
        Maze[2][5] = 1;
		Maze[4][5] = 1;
		Maze[0][1] = 1;
        Maze[1][0] = 1;
		Maze[1][1] = 1;
		Maze[1][2] = 0;
		Maze[1][3] = 1;
		Maze[1][4] = 1;
		Maze[1][5] = 1;
		Maze[3][3] = 1;
		Maze[4][3] = 0;
	}


	private static void addFrontier(ArrayList<int[]> reachableCells) {
		for (int[] cell : reachableCells){
			if (Maze[cell[0]][cell[1]]==0){
				frontierSet.add(Arrays.toString(cell));
			}
		}
	}

	private static void updateVisited(ArrayList<int[]> reachableCells) {
		boolean foundUnexplored = false;
		int[] newCurrPos = new int[2];
		for (int[] cell : reachableCells){
			if (Maze[cell[0]][cell[1]]==0){
				foundUnexplored = true;
				newCurrPos = cell;
				break;
			}
		}
		if (!foundUnexplored){
			newCurrPos = visitedStack.pop();
		}
		else{
			visitedStack.push(currPos);
		}
		currPos = newCurrPos;	
	}

	private static void visit() {
		if (frontierSet.contains(Arrays.toString(currPos))){
			frontierSet.remove(Arrays.toString(currPos));
		}
	}

	private static ArrayList<int[]> frontier() {
		ArrayList<int[]> reachableCells = new ArrayList<>();
		ArrayList<int[]> validCoordinates = getValidMazeCoordinates();
		for (int [] validCoord : validCoordinates){
			Maze[validCoord[0]][validCoord[1]] = Maze[validCoord[0]][validCoord[1]];
			if (Maze[validCoord[0]][validCoord[1]]==0){
				int[] reachableCell = findReachableCell(validCoord);
				reachableCells.add(reachableCell);
			}
		}
		return reachableCells;
	}


	private static int[] findReachableCell(int[] validCoord) {
		int dx = validCoord[0]- currPos[0];
		int dy = validCoord[1] - currPos[1];
		int[] reachableCell;
		if (dx == 1){
			reachableCell =  new int[]{currPos[0]+dx+1, currPos[1]};
		}
		else if (dx == -1){
			reachableCell =  new int[]{currPos[0]+dx-1, currPos[1]};
		}
		else if (dy == 1){
			reachableCell =  new int[]{currPos[0], currPos[1] + dy +1};
		}
		else{
			reachableCell =  new int[]{currPos[0], currPos[1] + dy -1};
		}
		return reachableCell;
	}
	
	private static ArrayList<int[]> getValidMazeCoordinates() {
		ArrayList<int[]> validMazeCoordinates = new ArrayList<int[]>();

		if (currPos[0]+1 <=6){
			validMazeCoordinates.add(new int[]{currPos[0]+1, currPos[1]});
		}
		if (currPos[0]-1 >=0){
			validMazeCoordinates.add(new int[]{currPos[0]-1, currPos[1]});
		}
		if (currPos[1] +1 <=8){
			validMazeCoordinates.add(new int[]{currPos[0], currPos[1]+1});
		}
		if (currPos[1] -1 >=0){
			validMazeCoordinates.add(new int[]{currPos[0], currPos[1]-1});
		}
		return validMazeCoordinates;
	}
	private static void initializeCurrPos() {
		currPos[0] = 0;
		currPos[1] = 2;
	}
}
	

