<h1>Minesweeper App</h1>
    <p>
        Welcome to the Minesweeper App, a modern take on the classic Minesweeper game built with Flutter. This app introduces additional features to enhance the gaming experience, making it more exciting and challenging.
    </p>
   <h2>Features</h2>
    <ul>
        <li><strong>Classic Minesweeper Gameplay</strong>: Enjoy the traditional Minesweeper game where you need to clear a board without detonating any mines.</li>
        <li><strong>Adjustable Difficulty</strong>: Select the number of mines you want to play with, ranging from 10 to half the total number of cells, with increments of 5.</li>
        <li><strong>Cell Timer</strong>: Each cell selection must be made within 5 seconds, adding a thrilling time-pressure element.</li>
        <li><strong>Vibration Feedback</strong>: Experience tactile feedback when flagging a cell, making the game more interactive.</li>
        <li><strong>Best Time Tracking</strong>: The app tracks and saves your best time and the corresponding number of mines for added motivation.</li>
    </ul>
    <h2>Technologies Used</h2>
    <ul>
        <li><strong>Flutter</strong>: The primary framework used for building the app, enabling cross-platform compatibility for both iOS and Android.</li>
        <li><strong>Dart</strong>: The programming language used with Flutter for developing the app's logic and UI.</li>
        <li><strong>Shared Preferences</strong>: Utilized for saving the best time and the corresponding number of mines locally on the device.</li>
        <li><strong>Vibration Package</strong>: Integrated to provide vibration feedback when a cell is flagged.</li>
    </ul>
    <h2>Getting Started</h2>
    <h3>Prerequisites</h3>
    <p>
        Ensure you have Flutter installed on your development environment. You can follow the official <a href="https://flutter.dev/docs/get-started/install">Flutter installation guide</a> to set it up.
    </p>
    <h3>Installation</h3>
    <ol>
        <li>Clone the repository:
            <pre><code>git clone https://github.com/cankirkgz/Minesweeper.git</code></pre>
        </li>
        <li>Navigate to the project directory:
            <pre><code>cd minesweeper_app</code></pre>
        </li>
        <li>Get the dependencies:
            <pre><code>flutter pub get</code></pre>
        </li>
    </ol>
    <h3>Running the App</h3>
    <p>To run the app on your connected device or emulator, use the following command:</p>
    <pre><code>flutter run</code></pre>
    <h2>Project Structure</h2>
    <ul>
        <li><code>main.dart</code>: Entry point of the application.</li>
        <li><code>screens/minesweeper_home_page.dart</code>: Contains the main game logic and UI.</li>
        <li><code>models/board.dart</code>: Defines the Board class, handling the game board logic.</li>
        <li><code>models/cell.dart</code>: Defines the Cell class, representing each cell on the board.</li>
        <li><code>widgets/board_widget.dart</code>: Contains the BoardWidget class for displaying the game board.</li>
        <li><code>widgets/cell_widget.dart</code>: Contains the CellWidget class for displaying each cell.</li>
    </ul>
    <h2>How to Play</h2>
    <ol>
        <li><strong>Objective</strong>: The goal is to clear the board without triggering any mines.</li>
        <li><strong>Controls</strong>:
            <ul>
                <li><strong>Tap</strong>: Reveal a cell.</li>
                <li><strong>Long Press</strong>: Flag a cell as a mine.</li>
            </ul>
        </li>
        <li><strong>Rules</strong>:
            <ul>
                <li>If you reveal a mine, the game ends.</li>
                <li>If you flag all the mines correctly and reveal all other cells, you win.</li>
                <li>You have 5 seconds to make each cell selection.</li>
            </ul>
        </li>
        <li><strong>Timer</strong>: The game tracks your time, and the best time for each mine count is saved.</li>
    </ol>
    <h2>Additional Features</h2>
    <ul>
        <li><strong>Dynamic Difficulty</strong>: Adjust the number of mines dynamically using a slider.</li>
        <li><strong>Real-time Feedback</strong>: Vibration feedback on flagging cells.</li>
        <li><strong>Statistics</strong>: Track and save your best performance times.</li>
    </ul>
    <h2>Contributing</h2>
    <p>
        Contributions are welcome! Please fork this repository, make your changes, and submit a pull request.
    </p>
    <h2>License</h2>
    <p>
        This project is licensed under the MIT License. See the <a href="LICENSE">LICENSE</a> file for details.
    </p>
