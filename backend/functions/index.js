const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Return waste credits and area rank (dummy values)
exports.getUserStats = onRequest((req, res) => {

  const dummyData = {
    credits: 480,
    areaRank: 12
  };

  res.status(200).json(dummyData);
});

exports.getTopLeaderboard = onRequest((req, res) => {
    const dummyData = {
     leaders:[
        { name: "Alice", score: 1000, rank: 1 },
        { name: "Bob", score: 980, rank: 2 },
        { name: "Charlie", score: 950, rank: 3 }
    ]};
    res.status(200).json(dummyData);
});


exports.getBinDisposalGuidlines = onRequest((req, res) => {
    //check for the bin type
    const binType = req.query.type;

    if (!binType) {
        return res.status(400).send("Bin type is required");
    }

    // Dummy data for bin disposal guidelines
    const guidelines = {
        organic: [
            {
                id: 1,
                title: "Separate Properly",
                description: "Keep organic waste apart from plastics, metals, and non-biodegradables."
            },
            {
                id: 2,
                title: "Compost at Home",
                description: "Convert food scraps and garden waste into nutrient-rich compost."
            },
            {
                id: 3,
                title: "Use Collection Services",
                description: "Dispose of organic waste in designated community compost bins."
            },
            {
                id: 4,
                title: "Avoid Contamination",
                description: "Don't mix organic waste with plastic or hazardous materials."
            },
            {
                id: 5,
                title: "No Processed Foods",
                description: "Avoid adding meat, dairy, or oily foods into home compost."
            },
            {
                id: 6,
                title: "Shred Large Waste",
                description: "Break down large pieces to accelerate composting."
            },
            {
                id: 7,
                title: "Cover Compost",
                description: "Keep compost piles covered to retain moisture and avoid pests."
            }
        ],
        paper: [
            {
                id: 1,
                title: "Recycle Clean Paper",
                description: "Only recycle dry, clean paper products like office paper or newspapers."
            },
            {
                id: 2,
                title: "Avoid Coated Paper",
                description: "Do not recycle laminated, waxed, or foil-lined papers."
            },
            {
                id: 3,
                title: "Flatten Boxes",
                description: "Flatten cartons and boxes to save bin space."
            },
            {
                id: 4,
                title: "No Food Contamination",
                description: "Pizza boxes and food-soiled paper should not be recycled."
            },
            {
                id: 5,
                title: "Remove Staples",
                description: "Remove clips or bindings from paper before recycling."
            },
            {
                id: 6,
                title: "Recycle Envelopes",
                description: "Even windowed envelopes can usually be recycled."
            },
            {
                id: 7,
                title: "Avoid Wet Paper",
                description: "Wet paper loses its recyclability. Keep it dry."
            }
        ],
        glass_plastic: [
            {
                id: 1,
                title: "Rinse Containers",
                description: "Wash out bottles and jars before recycling."
            },
            {
                id: 2,
                title: "Sort by Type",
                description: "Some areas require sorting by glass or plastic type."
            },
            {
                id: 3,
                title: "Remove Caps",
                description: "Plastic and metal caps should be removed from bottles."
            },
            {
                id: 4,
                title: "Do Not Recycle Broken Glass",
                description: "Broken glass should be disposed of safely, not recycled."
            },
            {
                id: 5,
                title: "Avoid Plastic Bags",
                description: "Plastic bags clog machines and must be recycled separately."
            },
            {
                id: 6,
                title: "Check Labels",
                description: "Look for recycling symbols to determine acceptability."
            },
            {
                id: 7,
                title: "Reuse When Possible",
                description: "Consider reusing jars and containers around the home."
            },
            {
                id: 8,
                title: "Avoid Colored Glass",
                description: "Colored glass often has limited recyclability."
            }
        ],
        miscellaneous: [
            {
                id: 1,
                title: "Check Local Rules",
                description: "Local councils may have special instructions for unique waste types."
            },
            {
                id: 2,
                title: "Electronic Waste",
                description: "Dispose of batteries, phones, and gadgets at e-waste centers."
            },
            {
                id: 3,
                title: "Hazardous Waste",
                description: "Items like paint, chemicals, and cleaners need special handling."
            },
            {
                id: 4,
                title: "Clothing & Textiles",
                description: "Donate usable clothes or recycle textiles at designated centers."
            },
            {
                id: 5,
                title: "Furniture & Bulk Items",
                description: "Schedule a pickup or drop-off with your local waste services."
            },
            {
                id: 6,
                title: "Ceramics & China",
                description: "These do not go in glass bins. Dispose of with general waste."
            },
            {
                id: 7,
                title: "Medical Waste",
                description: "Needles, masks, and medicine must go to health-safe collection points."
            }
        ]
    };
    

    // Check if the bin type exists in the guidelines
    if (!guidelines[binType]) {
        return res.status(404).send("No guidelines found for this bin type");
    }

    // Return the guidelines for the specified bin type
    res.status(200).json(guidelines[binType]);
});
