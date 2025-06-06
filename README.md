# PDMIU Project  
## My Green Space  

**Student**: Francesco Pio Rossi  
**Student ID**: 331825  
**Professor**: Cuno Lorenz Klopfenstein  
**Exam Session**: June 2025  

## Application Overview  

**My Green Space** is a Flutter application designed to help users manage their personal home gardens. The app features a plant catalog where users can browse a limited selection of plants and view key information such as a short description, optimal temperature, transplanting period, and more.  

Users can create instances from this catalog to represent their own personal plants. Each personal plant is assigned a unique ID, and users can store specific information for each one — such as its location, a list of irrigation records, personal notes, and photos documenting the plant's growth over time. Additionally, users can maintain a to-do list related to garden care and maintenance.  

## Technical Details  

The app uses the **Riverpod** library for state management. User data is stored in **Supabase**, an online relational database. Supabase's storage feature is also used to save user-uploaded plant photos. For managing the local state — specifically the to-do list — the **shared_preferences** package is utilized.  

 ## Homepage and Navigation Between Different Pages
 
The homepage displays a preview of some random plants from the catalog as well as a selection of plants from the user’s personal garden. By tapping on a specific plant card, the user can navigate to the detailed page of that plant—either from the garden or the catalog. Additionally, the homepage shows the user's to-do list, which is stored locally using the `shared_preferences` package.

![Homepage](assets/homepage.jpeg)

The drawer allows the user to navigate to the plant catalog page or to the personal plants page. Before navigating to a specific page through the drawer, the navigation stack is cleared, preventing the user from going back to the previous page.

![Drawer](assets/drawer.jpeg)

## Management of Catalog Plants
The catalog page displays the full list of plants available in the app, from which the user can create instances representing the plants in their personal garden.

![Catalog](assets/catalog.jpeg)

By tapping on a card, the user is taken to a detailed page with more information about the selected plant.

![Plant catalog details](assets/plant_catalog_details.jpeg)

Each plant in the catalog is associated with a set of tags. The user can filter the plant list by selecting a subset of tags: only the plants that contain **all** the selected tags will be shown. 

When the user wants to create an instance of a plant to represent one in its garden, he can set various details such as the planting date, the position, and a list of notes. He can also change the image associated with the plant.

![Add a new plant](assets/add_plant.jpeg)

In this application, state management is entirely handled using Riverpod. For example, the data related to the catalog plants is managed through the following providers:

- **plantCatalogProvider**: provides a list of `Plant` objects. The data is loaded from a JSON file.
- **allTagsProvider**: provides a list of strings representing all available tags.
- **selectedTagsProvider**: a `StateProvider` that holds the list of currently selected tags.
- **filteredPlantsProvider**: provides the list of plants that match **all** the currently selected tags.
- **selectedPlantProvider**: provides the currently selected plant when a detail page is open.





 
 
